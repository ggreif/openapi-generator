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
import io.swagger.v3.oas.models.media.Schema;

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
        supportingFiles.add(new SupportingFile("enumMappings.mustache", "", "EnumMappings.mo"));

        // Motoko reserved words
        // Based on Motoko language specification
        reservedWords.addAll(Arrays.asList(
            "actor", "and", "assert", "async", "await", "break", "case", "catch", "class",
            "continue", "debug", "do", "else", "false", "for", "func", "if",
            "in", "import", "module", "not", "null", "object", "or", "label",
            "let", "loop", "private", "public", "query", "return", "shared", "switch",
            "system", "throw", "true", "try", "type", "var", "while", "with",
            // Core library types and primitives that could conflict with user-defined models
            // NOTE: Must be lowercase as isReservedWord() converts to lowercase before checking
            "text", "char", "bool", "int", "float", "blob", "any", "map"
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
        // Map AnyType (from additionalProperties/free-form objects) to Text as a placeholder
        // TODO: Better support for additionalProperties - see related TODO in postProcessModels
        typeMapping.put("AnyType", "Text");

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

    @Override
    public String toModelName(String name) {
        // Apply parent sanitization first
        name = super.toModelName(name);

        // Check if model name conflicts with reserved words or Motoko primitives
        if (isReservedWord(name)) {
            return escapeReservedWord(name);
        }

        return name;
    }

    @Override
    public String toModelFilename(String name) {
        // Filename should match the model name
        return toModelName(name);
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
    public String toEnumVarName(String name, String datatype) {
        // Check for custom mapping
        if (enumNameMapping.containsKey(name)) {
            return enumNameMapping.get(name);
        }

        // Handle empty string
        if (name == null || name.isEmpty()) {
            return "empty";
        }

        // For purely numeric values (Candid-style), wrap with underscores
        if (name.matches("^\\d+$")) {
            return "_" + name + "_";
        }

        // Lowercase for Motoko variant convention (idiomatic, though not required)
        String enumVarName = name.toLowerCase(Locale.ROOT);

        // Replace special characters with underscores
        // Motoko identifiers: [a-zA-Z_][a-zA-Z0-9_]*
        enumVarName = enumVarName.replaceAll("[^a-zA-Z0-9_]", "_");

        // Remove consecutive underscores
        enumVarName = enumVarName.replaceAll("_+", "_");

        // Remove leading/trailing underscores
        enumVarName = enumVarName.replaceAll("^_+|_+$", "");

        // If name starts with a number (but not purely numeric), prefix with underscore
        if (enumVarName.matches("^\\d.*")) {
            enumVarName = "_" + enumVarName;
        }

        // Fallback for invalid names after sanitization
        if (enumVarName.isEmpty()) {
            enumVarName = "value_" + Math.abs(name.hashCode());
        }

        // Escape reserved words
        if (isReservedWord(enumVarName)) {
            return escapeReservedWord(enumVarName);
        }

        return enumVarName;
    }

    @Override
    public String toEnumName(CodegenProperty property) {
        // Check for custom mapping
        if (enumNameMapping.containsKey(property.name)) {
            return enumNameMapping.get(property.name);
        }

        // Use the property's base name to create enum type name
        String enumName = toModelName(property.baseName);

        // Avoid collision with property variable name by checking if they would be identical
        // For example, if property is "status", enum type should be "Status" not "status"
        if (enumName.equals(property.name)) {
            enumName = enumName + "Enum";
        }

        // Check for reserved word collision
        if (isReservedWord(enumName)) {
            enumName = escapeReservedWord(enumName);
        }

        return enumName;
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

        // For enum parameters, ensure enumVars are built for template use
        if (Boolean.TRUE.equals(parameter.isEnum) && parameter.allowableValues != null) {
            @SuppressWarnings("unchecked")
            List<Object> values = (List<Object>) parameter.allowableValues.get("values");

            if (values != null && !values.isEmpty()) {
                List<Map<String, Object>> enumVars = new ArrayList<>();
                for (int i = 0; i < values.size(); i++) {
                    Object value = values.get(i);
                    Map<String, Object> enumVar = new HashMap<>();

                    // Get the variant name using toEnumVarName
                    String variantName = toEnumVarName(String.valueOf(value), parameter.dataType);

                    enumVar.put("name", variantName);
                    enumVar.put("value", String.valueOf(value));
                    enumVar.put("isString", value instanceof String);

                    // Mark the last item
                    if (i == values.size() - 1) {
                        enumVar.put("-last", true);
                    }

                    enumVars.add(enumVar);
                }
                parameter.allowableValues.put("enumVars", enumVars);
            }
        }
    }

    @Override
    public CodegenModel fromModel(String name, Schema schema) {
        CodegenModel model = super.fromModel(name, schema);

        // For standalone enum schemas, ensure enumVars are built
        if (Boolean.TRUE.equals(model.isEnum) && model.allowableValues != null) {
            @SuppressWarnings("unchecked")
            List<Object> values = (List<Object>) model.allowableValues.get("values");

            if (values != null && !values.isEmpty()) {
                List<Map<String, Object>> enumVars = new ArrayList<>();
                for (int i = 0; i < values.size(); i++) {
                    Object value = values.get(i);
                    Map<String, Object> enumVar = new HashMap<>();

                    // Get the variant name using toEnumVarName
                    String variantName = toEnumVarName(String.valueOf(value), model.dataType);

                    enumVar.put("name", variantName);
                    enumVar.put("value", String.valueOf(value));
                    enumVar.put("isString", value instanceof String);

                    // Mark the last item
                    if (i == values.size() - 1) {
                        enumVar.put("-last", true);
                    }

                    enumVars.add(enumVar);
                }
                model.allowableValues.put("enumVars", enumVars);
            }
        }

        return model;
    }

    @Override
    public ModelsMap postProcessModelsEnum(ModelsMap objs) {
        // Call parent to process enums with default logic
        objs = super.postProcessModelsEnum(objs);

        return objs;
    }

    @Override
    public ModelsMap postProcessModels(ModelsMap objs) {
        // Call parent first (which calls postProcessModelsEnum internally)
        objs = super.postProcessModels(objs);

        // Track enum models to add to imports
        Set<String> enumModelNames = new HashSet<>();

        // Check if we need to import Map
        boolean needsMapImport = false;

        // Collect enum and field mappings for JSON serialization
        Map<String, List<Map<String, String>>> enumMappings = new HashMap<>();
        Map<String, List<Map<String, String>>> fieldMappings = new HashMap<>();

        // Check all model properties for Map usage and enum references
        List<ModelMap> models = objs.getModels();
        if (models != null) {
            for (ModelMap modelMap : models) {
                org.openapitools.codegen.CodegenModel model = modelMap.getModel();

                if (model != null) {
                    // Track if this model itself is an enum
                    if (Boolean.TRUE.equals(model.isEnum)) {
                        enumModelNames.add(model.classname);
                        // Mark enum models for conditional template logic
                        model.vendorExtensions.put("x-is-motoko-enum", true);

                        // Collect enum variant mappings
                        List<Map<String, String>> mappings = collectEnumMappings(model);
                        if (!mappings.isEmpty()) {
                            enumMappings.put(model.classname, mappings);
                            model.vendorExtensions.put("x-has-enum-mappings", true);
                            model.vendorExtensions.put("x-enum-mappings", mappings);
                        }
                    }

                    if (model.vars != null) {
                        // Collect field name mappings
                        List<Map<String, String>> fieldEscapeMappings = new ArrayList<>();

                        for (org.openapitools.codegen.CodegenProperty prop : model.vars) {
                            // Check for Map usage
                            if (prop.dataType != null && prop.dataType.contains("Map<")) {
                                needsMapImport = true;
                            }

                            // Collect escaped field names (where Motoko name differs from JSON name)
                            if (!prop.baseName.equals(prop.name)) {
                                Map<String, String> mapping = new HashMap<>();
                                mapping.put("motokoName", prop.name);
                                mapping.put("jsonName", prop.baseName);
                                fieldEscapeMappings.add(mapping);
                            }

                            // Handle enum properties
                            if (Boolean.TRUE.equals(prop.isEnum)) {
                                // TODO: Inline enums need proper implementation to generate separate model files
                                // For now, keep them as Text type
                                // This is an inline enum - would need to generate a separate model for it
                                // String enumTypeName = toEnumName(prop);
                                // prop.datatypeWithEnum = enumTypeName;
                                // prop.dataType = enumTypeName;
                                // enumModelNames.add(enumTypeName);
                            } else if (Boolean.TRUE.equals(prop.isEnumRef)) {
                                // This is a reference to an existing enum
                                // The datatypeWithEnum should already be set by DefaultCodegen
                                if (prop.datatypeWithEnum != null) {
                                    prop.vendorExtensions.put("x-is-motoko-enum", true);
                                    prop.vendorExtensions.put("x-motoko-enum-type", prop.datatypeWithEnum);
                                    enumModelNames.add(prop.datatypeWithEnum);
                                }
                            }
                        }

                        // Store field mappings if any
                        if (!fieldEscapeMappings.isEmpty()) {
                            fieldMappings.put(model.classname, fieldEscapeMappings);
                            model.vendorExtensions.put("x-has-field-mappings", true);
                            model.vendorExtensions.put("x-field-mappings", fieldEscapeMappings);
                        }
                    }
                }
            }
        }

        // Store mappings in context for templates
        objs.put("enumMappings", enumMappings);
        objs.put("fieldMappings", fieldMappings);
        objs.put("hasAnyMappings", !enumMappings.isEmpty() || !fieldMappings.isEmpty());

        // Mark imports that are mapped types (primitives) or array/map types so they can be filtered out
        List<Map<String, String>> imports = objs.getImports();
        if (imports != null) {
            for (Map<String, String> im : imports) {
                String importName = im.get("import");
                // Check if this import is a primitive/mapped type or array/map type
                if (importName != null) {
                    // TODO: Support additionalProperties by modeling as Map<Text, Text> or similar
                    //   Currently schemas with additionalProperties: true are not fully supported.
                    //   Future work: Add a field like "additionalProperties: ?Map<Text, Text>" to models.
                    boolean isMappedType = typeMapping.containsKey(importName) ||
                                            typeMapping.containsValue(importName) ||
                                            languageSpecificPrimitives.contains(importName) ||
                                            importName.startsWith("[") ||
                                            importName.contains("<") ||     // Filter out parameterized types like "Map<Text, Int>"
                                            "AnyType".equals(importName);   // Filter out AnyType - not yet implemented
                    if (isMappedType) {
                        im.put("isMappedType", "true");
                    }

                    // Mark enum imports
                    if (enumModelNames.contains(importName)) {
                        im.put("isEnum", "true");
                    }
                }
            }
        }

        // Add Map import if needed
        // NOTE: Model name escaping is implemented in toModelName() and tested in
        //       samples/client/type-coverage/motoko-test with a user-defined "Map" model.
        //       User model "Map" is escaped to "Map_" while Map<K,V> refers to the core type.
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

    /**
     * Collect enum variant mappings for JSON serialization.
     * Returns a list of mappings where Motoko variant name differs from OpenAPI value.
     */
    private List<Map<String, String>> collectEnumMappings(CodegenModel model) {
        List<Map<String, String>> mappings = new ArrayList<>();

        if (model.allowableValues != null) {
            Object enumVarsObj = model.allowableValues.get("enumVars");
            if (enumVarsObj instanceof List<?>) {
                List<?> enumVars = (List<?>) enumVarsObj;
                for (Object enumVarObj : enumVars) {
                    if (enumVarObj instanceof Map<?, ?>) {
                        Map<?, ?> enumVar = (Map<?, ?>) enumVarObj;
                        String motokoName = (String) enumVar.get("name");
                        String jsonValue = (String) enumVar.get("value");

                        // Only add mapping if names differ
                        if (motokoName != null && jsonValue != null && !motokoName.equals(jsonValue)) {
                            Map<String, String> mapping = new HashMap<>();
                            mapping.put("motokoName", motokoName);
                            mapping.put("jsonValue", jsonValue);
                            mappings.add(mapping);
                        }
                    }
                }
            }
        }

        return mappings;
    }

    @Override
    public OperationsMap postProcessOperationsWithModels(OperationsMap objs, List<ModelMap> allModels) {
        OperationsMap result = super.postProcessOperationsWithModels(objs, allModels);

        // TODO: Authentication is missing - need to add support for:
        //   - OAuth 2.0 tokens in Authorization header
        //   - API keys in headers/query parameters
        //   - Other auth schemes defined in OpenAPI security definitions

        // Response code processing is implemented in api.mustache template
        // - HTTP status codes are checked before parsing (2xx vs 4xx/5xx)
        // - Error responses use generated error models when available
        // - Structured error details are included in thrown errors

        // Collect all enum types and models with escaped fields for global API context
        List<Map<String, Object>> allEnumTypes = new ArrayList<>();
        List<Map<String, Object>> allModelsWithEscapedFields = new ArrayList<>();

        if (allModels != null) {
            for (ModelMap modelMap : allModels) {
                CodegenModel model = modelMap.getModel();

                if (model != null) {
                    // Collect enum types with mappings
                    if (Boolean.TRUE.equals(model.isEnum) &&
                        Boolean.TRUE.equals(model.vendorExtensions.get("x-has-enum-mappings"))) {
                        Map<String, Object> enumInfo = new HashMap<>();
                        enumInfo.put("name", model.classname);
                        enumInfo.put("mappings", model.vendorExtensions.get("x-enum-mappings"));
                        allEnumTypes.add(enumInfo);
                    }

                    // Collect models with escaped field names
                    if (Boolean.TRUE.equals(model.vendorExtensions.get("x-has-field-mappings"))) {
                        Map<String, Object> modelInfo = new HashMap<>();
                        modelInfo.put("name", model.classname);
                        modelInfo.put("mappings", model.vendorExtensions.get("x-field-mappings"));
                        allModelsWithEscapedFields.add(modelInfo);
                    }
                }
            }
        }

        // Mark first/last items for template iteration (Mustache uses these for comma handling)
        // Clear any existing flags first
        for (Map<String, Object> enumInfo : allEnumTypes) {
            enumInfo.remove("-last");
            enumInfo.remove("-first");
        }
        for (Map<String, Object> modelInfo : allModelsWithEscapedFields) {
            modelInfo.remove("-last");
            modelInfo.remove("-first");
        }
        // Set flags on boundary items
        if (!allEnumTypes.isEmpty()) {
            allEnumTypes.get(allEnumTypes.size() - 1).put("-last", true);
        }
        if (!allModelsWithEscapedFields.isEmpty()) {
            allModelsWithEscapedFields.get(0).put("-first", true);
            allModelsWithEscapedFields.get(allModelsWithEscapedFields.size() - 1).put("-last", true);
        }

        // Store in context for API template
        result.put("allEnumTypes", allEnumTypes);
        result.put("allModelsWithEscapedFields", allModelsWithEscapedFields);
        result.put("hasAnyMappings", !allEnumTypes.isEmpty() || !allModelsWithEscapedFields.isEmpty());

        // Also add to additionalProperties for supporting files (EnumMappings.mustache)
        additionalProperties.put("allEnumTypes", allEnumTypes);
        additionalProperties.put("allModelsWithEscapedFields", allModelsWithEscapedFields);
        additionalProperties.put("hasAnyMappings", !allEnumTypes.isEmpty() || !allModelsWithEscapedFields.isEmpty());

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
                                            className.contains("<") ||     // Filter out parameterized types like "Map<Text, Int>"
                                            "AnyType".equals(className);   // Filter out AnyType - not yet implemented
                    // In Mustache, only add the key if it's true (for conditional sections)
                    if (isMappedType) {
                        im.put("isMappedType", "true");
                    }
                }
            }
        }

        // Add Map import if needed
        // NOTE: Model name escaping is implemented in toModelName() and tested in
        //       samples/client/type-coverage/motoko-test with a user-defined "Map" model.
        //       User model "Map" is escaped to "Map_" while Map<K,V> refers to the core type.
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
