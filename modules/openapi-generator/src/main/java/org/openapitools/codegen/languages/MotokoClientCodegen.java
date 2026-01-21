package org.openapitools.codegen.languages;

import org.openapitools.codegen.*;
import org.openapitools.codegen.model.ModelMap;
import org.openapitools.codegen.model.ModelsMap;
import org.openapitools.codegen.model.OperationsMap;
import org.openapitools.codegen.utils.ModelUtils;
import io.swagger.models.properties.ArrayProperty;
import io.swagger.models.properties.MapProperty;
import io.swagger.models.properties.Property;
import io.swagger.models.parameters.Parameter;

import java.io.File;
import java.util.*;

import org.apache.commons.lang3.StringUtils;

public class MotokoClientCodegen extends DefaultCodegen implements CodegenConfig {
    public static final String PROJECT_NAME = "projectName";
    public static final String USE_DFX = "useDfx";

    protected String projectName = "OpenAPI";
    protected boolean useDfx = false;

    public CodegenType getTag() {
        return CodegenType.CLIENT;
    }

    public String getName() {
        return "motoko";
    }

    public String getHelp() {
        return "Generates a Motoko OpenAPI client module.";
    }

    public MotokoClientCodegen() {
        super();

        outputFolder = "generated-code" + File.separator + "motoko";
        modelTemplateFiles.put("model.mustache", ".mo");
        apiTemplateFiles.put("api.mustache", ".mo");
        embeddedTemplateDir = templateDir = "motoko";
        apiPackage = "Apis";
        modelPackage = "Models";
        supportingFiles.add(new SupportingFile("README.mustache", "", "README.md"));

        // Motoko language-specific primitives (don't need imports)
        languageSpecificPrimitives.clear();
        languageSpecificPrimitives.add("Text");
        languageSpecificPrimitives.add("Char");
        languageSpecificPrimitives.add("Bool");
        languageSpecificPrimitives.add("Int");
        languageSpecificPrimitives.add("Float");
        languageSpecificPrimitives.add("Blob");
        languageSpecificPrimitives.add("Any");

        // Motoko type mappings
        typeMapping.clear();
        typeMapping.put("string", "Text");
        typeMapping.put("char", "Char");
        typeMapping.put("boolean", "Bool");
        typeMapping.put("int", "Int");
        typeMapping.put("integer", "Int");
        typeMapping.put("long", "Int");
        typeMapping.put("float", "Float");
        typeMapping.put("double", "Float");
        typeMapping.put("number", "Float");
        typeMapping.put("date", "Text");
        typeMapping.put("DateTime", "Text");
        typeMapping.put("password", "Text");
        typeMapping.put("file", "Blob");
        typeMapping.put("binary", "Blob");
        typeMapping.put("ByteArray", "Blob");
        typeMapping.put("UUID", "Text");
        typeMapping.put("URI", "Text");
        typeMapping.put("array", "Array");  // Handled in getTypeDeclaration to produce [T] syntax
        typeMapping.put("map", "HashMap");  // Handled in getTypeDeclaration to produce [Text: T] syntax
        typeMapping.put("object", "Any");

        cliOptions.add(CliOption.newString(PROJECT_NAME, "Project name for generated code"));
        cliOptions.add(CliOption.newBoolean(USE_DFX, "Generate code for dfx with ic:aaaaa-aa imports", useDfx));
    }

    @Override
    public void processOpts() {
        super.processOpts();

        if (additionalProperties.containsKey(PROJECT_NAME)) {
            setProjectName((String) additionalProperties.get(PROJECT_NAME));
        }

        if (additionalProperties.containsKey(USE_DFX)) {
            setUseDfx(convertPropertyToBooleanAndWriteBack(USE_DFX));
        }
        additionalProperties.put(USE_DFX, useDfx);
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setUseDfx(boolean useDfx) {
        this.useDfx = useDfx;
    }

    public boolean getUseDfx() {
        return useDfx;
    }

    @Override
    public String toModelImport(String name) {
        // For Motoko, imports are relative to the current Models directory
        // Just return the model name without package prefix
        return name;
    }

    @Override
    public String getTypeDeclaration(io.swagger.v3.oas.models.media.Schema schema) {
        // Handle array types: convert to Motoko syntax [ElementType]
        String result;
        if (ModelUtils.isArraySchema(schema)) {
            io.swagger.v3.oas.models.media.Schema inner = ModelUtils.getSchemaItems(schema);
            result = "[" + getTypeDeclaration(inner) + "]";

            return result;
        } else if (ModelUtils.isMapSchema(schema)) {
            // Handle map types: convert to Motoko syntax [Text: ValueType]
            io.swagger.v3.oas.models.media.Schema inner = ModelUtils.getAdditionalProperties(schema);
            result = "[Text: " + getTypeDeclaration(inner) + "]";

            return result;
        }

        return super.getTypeDeclaration(schema);
    }

    @Override
    public String getSchemaType(io.swagger.v3.oas.models.media.Schema schema) {
        // Handle array types first, before calling super.getSchemaType()
        // This is critical because super.getSchemaType() returns "array" without the element type
        if (ModelUtils.isArraySchema(schema)) {
            String inner = getSchemaType(ModelUtils.getSchemaItems(schema));
            return "[" + inner + "]";
        } else if (ModelUtils.isMapSchema(schema)) {
            io.swagger.v3.oas.models.media.Schema inner = ModelUtils.getAdditionalProperties(schema);
            return "[Text: " + getSchemaType(inner) + "]"; // TODO: Use core/Map
        }

        String openAPIType = super.getSchemaType(schema);
        String type;
        // Check if we have a type mapping for this OpenAPI type
        if (typeMapping.containsKey(openAPIType)) {
            type = typeMapping.get(openAPIType);
            // If it's a language-specific primitive, return it directly
            if (languageSpecificPrimitives.contains(type)) {
                return type;
            }
        } else {
            type = openAPIType;
        }
        // Otherwise, convert to model name
        return toModelName(type);
    }

    @Override
    public String toInstantiationType(io.swagger.v3.oas.models.media.Schema schema) {
        if (ModelUtils.isMapSchema(schema)) {
            io.swagger.v3.oas.models.media.Schema inner = ModelUtils.getAdditionalProperties(schema);
            return "[Text: " + getSchemaType(inner) + "]"; // TODO: Use core/Map
        } else if (ModelUtils.isArraySchema(schema)) {
            String inner = getSchemaType(ModelUtils.getSchemaItems(schema));
            return "[" + inner + "]";
        }
        return null;
    }

    @Override
    public void postProcessParameter(CodegenParameter parameter) {
        super.postProcessParameter(parameter);

        // Fix dataType for arrays and maps that may have slipped through as bare types
        // This happens when the dataType is set before our getSchemaType is called
        if ("array".equals(parameter.dataType) || "Array".equals(parameter.dataType)) { // TODO: is comparison agains "Array" necessary?
            // Try to reconstruct the array type from the parameter
            if (parameter.isArray && parameter.items != null) {
                // items is a CodegenProperty, not CodegenParameter - just use its dataType
                String old = parameter.dataType;
                parameter.dataType = "[" + parameter.items.dataType + "]"; // TODO: what if parameter.items.dataType is itself a collection?
            }
        }
    }

    @Override
    public ModelsMap postProcessModels(ModelsMap objs) {
        // Call parent first
        objs = super.postProcessModels(objs);
        // Process enum models
        objs = postProcessModelsEnum(objs);

        // Mark imports that are mapped types (primitives) or array/map types so they can be filtered out
        List<Map<String, String>> imports = objs.getImports();
        if (imports != null) {
            for (Map<String, String> im : imports) {
                String importName = im.get("import");
                // Check if this import is a primitive/mapped type or array/map type
                if (importName != null) {
                    boolean isMappedType = typeMapping.containsKey(importName) ||
                                            typeMapping.containsValue(importName) ||
                                            languageSpecificPrimitives.contains(importName) ||
                                            importName.startsWith("[");
                    if (isMappedType) {
                        im.put("isMappedType", "true");
                    }
                }
            }
        }

        return objs;
    }

    @Override
    public OperationsMap postProcessOperationsWithModels(OperationsMap objs, List<ModelMap> allModels) {
        OperationsMap result = super.postProcessOperationsWithModels(objs, allModels);

        // Fix array types in operations
        org.openapitools.codegen.model.OperationMap operations = result.getOperations();
        if (operations != null) {
            for (org.openapitools.codegen.CodegenOperation op : operations.getOperation()) {
                // Fix return type if it's a bare "array"
                if ("array".equals(op.returnType) || "Array".equals(op.returnType)) { // TODO: is comparison agains "Array" necessary?
                    if (op.returnContainer != null && op.returnContainer.equals("array")) {
                        op.returnType = "[" + op.returnBaseType + "]";
                    }
                }
            }
        }

        // Mark imports that are mapped types (primitives) or array/map types so they can be filtered out
        List<Map<String, String>> imports = result.getImports();
        if (imports != null) {
            for (Map<String, String> im : imports) {
                // Get the classname field - this is what we use in the template
                String className = im.get("classname");
                // Check if this classname is a key in typeMapping (meaning it's a primitive/mapped type)
                // OR if it starts with '[' (array/map type) which shouldn't be imported
                if (className != null) {
                    boolean isMappedType = typeMapping.containsKey(className) ||
                                            className.startsWith("[");
                    // In Mustache, only add the key if it's true (for conditional sections)
                    if (isMappedType) {
                        im.put("isMappedType", "true");
                    }
                }
            }
        }

        return result;
    }
}
