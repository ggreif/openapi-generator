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
        supportingFiles.add(new SupportingFile("mops.toml.mustache", "", "mops.toml"));

        // Motoko reserved words
        // Based on Motoko language specification
        reservedWords.addAll(Arrays.asList(
            "actor", "and", "async", "await", "break", "case", "catch", "class",
            "continue", "debug", "do", "else", "false", "for", "func", "if",
            "in", "import", "module", "not", "null", "object", "or", "label",
            "let", "loop", "private", "public", "return", "shared", "switch",
            "throw", "true", "try", "type", "var", "while", "with",
            // Core library types and primitives that could conflict with user-defined models
            "Text", "Char", "Bool", "Int", "Float", "Blob", "Any", "Map"
        ));

        // Motoko language-specific primitives (don't need imports)
        languageSpecificPrimitives.clear();
        languageSpecificPrimitives.addAll(Arrays.asList(
            "Text", "Char", "Bool", "Int", "Float", "Blob", "Any"
        ));

        // Motoko type mappings
        typeMapping.clear();
        typeMapping.putAll(Map.of(
            "string", "Text",
            "char", "Char",
            "boolean", "Bool",
            "int", "Int",
            "integer", "Int",
            "long", "Int",
            "float", "Float",
            "double", "Float",
            "number", "Float",
            "date", "Text"
        ));
        typeMapping.putAll(Map.of(
            "DateTime", "Text",
            "password", "Text",
            "file", "Blob",
            "binary", "Blob",
            "ByteArray", "Blob",
            "UUID", "Text",
            "URI", "Text",
            "array", "Array",  // Handled in getTypeDeclaration to produce [T] syntax
            "map", "Map",  // Maps use the red-black tree based Map from core/pure/Map
            "object", "Any"
        ));

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

    @Override
    public String escapeReservedWord(String name) {
        // Escape reserved words and Motoko primitives/core types by appending underscore
        if (this.reservedWordsMappings().containsKey(name)) {
            return this.reservedWordsMappings().get(name);
        }
        return name + "_";
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
    public String escapeReservedWord(String name) {
        // Per Internet Computer IDL-Motoko spec:
        // Reserved keywords are escaped by appending an underscore "_"
        // See: https://github.com/dfinity/motoko/blob/master/design/IDL-Motoko.md
        return name + "_";
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
            // Handle map types: convert to Motoko Map syntax Map<Text, ValueType>
            io.swagger.v3.oas.models.media.Schema inner = ModelUtils.getAdditionalProperties(schema);
            result = "Map<Text, " + getTypeDeclaration(inner) + ">";

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
            return "Map<Text, " + getSchemaType(inner) + ">";
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
        if (ModelUtils.isArraySchema(schema)) {
            String inner = getSchemaType(ModelUtils.getSchemaItems(schema));
            return "[" + inner + "]";
        } else if (ModelUtils.isMapSchema(schema)) {
            io.swagger.v3.oas.models.media.Schema inner = ModelUtils.getAdditionalProperties(schema);
            return "Map<Text, " + getSchemaType(inner) + ">";
        }
        return null;
    }

    @Override
    public void postProcessParameter(CodegenParameter parameter) {
        super.postProcessParameter(parameter);

        // Fix dataType for arrays and maps that may have slipped through as bare types
        // This happens when the dataType is set before our getSchemaType is called
        if ("array".equals(parameter.dataType)) {
            // Try to reconstruct the array type from the parameter
            if (parameter.isArray && parameter.items != null) {
                // items is a CodegenProperty, not CodegenParameter - just use its dataType
                String old = parameter.dataType;
                parameter.dataType = "[" + parameter.items.dataType + "]";
            }
        }
    }

    @Override
    public ModelsMap postProcessModels(ModelsMap objs) {
        // Call parent first
        objs = super.postProcessModels(objs);
        // Process enum models
        objs = postProcessModelsEnum(objs);

        // Check if we need to import Map
        boolean needsMapImport = false;

        // Check all model properties for Map usage
        List<ModelMap> models = objs.getModels();
        if (models != null) {
            for (ModelMap modelMap : models) {
                org.openapitools.codegen.CodegenModel model = modelMap.getModel();
                if (model != null && model.vars != null) {
                    for (org.openapitools.codegen.CodegenProperty prop : model.vars) {
                        if (prop.dataType != null && prop.dataType.contains("Map<")) {
                            needsMapImport = true;
                            break;
                        }
                    }
                }
                if (needsMapImport) break;
            }
        }

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
                                            importName.startsWith("[") ||
                                            importName.contains(".") ||  // Filter out type references like "Map.Map"
                                            importName.contains("<");     // Filter out parameterized types like "Map<Text, Int>"
                    if (isMappedType) {
                        im.put("isMappedType", "true");
                    }
                }
            }
        }

        // Add Map import if needed
        // TODO: Add end-to-end test for when OpenAPI spec contains a model named "Map"
        //       Similar to "Text" and other primitives, it will need escaping/renaming to avoid
        //       conflicts with the core library's Map type. Test should verify that user-defined
        //       "Map" model gets properly escaped (e.g., "Map_") while Map<K,V> type works correctly.
        if (needsMapImport) {
            if (imports == null) {
                imports = new ArrayList<>();
                objs.put("imports", imports);
            }
            imports.add(Map.of(
                "import", "Map",
                "isMap", "true",
                "isMappedType", "true"  // Prevent it from being imported as a model
            ));
        }

        return objs;
    }

    @Override
    public OperationsMap postProcessOperationsWithModels(OperationsMap objs, List<ModelMap> allModels) {
        OperationsMap result = super.postProcessOperationsWithModels(objs, allModels);

        // Check if we need to import Map
        boolean needsMapImport = false;

        // Fix array types in operations
        org.openapitools.codegen.model.OperationMap operations = result.getOperations();
        if (operations != null) {
            for (org.openapitools.codegen.CodegenOperation op : operations.getOperation()) {
                // Fix return type if it's a bare "array"
                if ("array".equals(op.returnType)) {
                    if (op.returnContainer != null && op.returnContainer.equals("array")) {
                        op.returnType = "[" + op.returnBaseType + "]";
                    }
                }

                // Check if return type uses Map
                if (op.returnType != null && op.returnType.contains("Map<")) {
                    needsMapImport = true;
                }

                // Check if any parameters use Map
                if (op.allParams != null) {
                    for (org.openapitools.codegen.CodegenParameter param : op.allParams) {
                        if (param.dataType != null && param.dataType.contains("Map<")) {
                            needsMapImport = true;
                            break;
                        }
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
                                            className.startsWith("[") ||
                                            className.contains(".") ||  // Filter out type references like "Map.Map"
                                            className.contains("<");     // Filter out parameterized types like "Map<Text, Int>"
                    // In Mustache, only add the key if it's true (for conditional sections)
                    if (isMappedType) {
                        im.put("isMappedType", "true");
                    }
                }
            }
        }

        // Add Map import if needed
        // TODO: Add end-to-end test for when OpenAPI spec contains a model named "Map"
        //       Similar to "Text" and other primitives, it will need escaping/renaming to avoid
        //       conflicts with the core library's Map type. Test should verify that user-defined
        //       "Map" model gets properly escaped (e.g., "Map_") while Map<K,V> type works correctly.
        if (needsMapImport) {
            if (imports == null) {
                imports = new ArrayList<>();
                result.put("imports", imports);
            }
            imports.add(Map.of(
                "import", "Map",
                "classname", "Map",
                "isMap", "true",
                "isMappedType", "true"  // Prevent it from being imported as a model
            ));
        }

        return result;
    }
}
