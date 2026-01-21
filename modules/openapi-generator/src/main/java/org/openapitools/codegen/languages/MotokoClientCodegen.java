package org.openapitools.codegen.languages;

import org.openapitools.codegen.*;
import io.swagger.models.properties.ArrayProperty;
import io.swagger.models.properties.MapProperty;
import io.swagger.models.properties.Property;
import io.swagger.models.parameters.Parameter;

import java.io.File;
import java.util.*;

import org.apache.commons.lang3.StringUtils;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MotokoClientCodegen extends DefaultCodegen implements CodegenConfig {
    public static final String PROJECT_NAME = "projectName";
    public static final String USE_DFX = "useDfx";

    private final Logger LOGGER = LoggerFactory.getLogger(MotokoClientCodegen.class);

    protected String projectName = "OpenAPI";
    protected boolean useDfx = false;

    public CodegenType getTag() {
        return CodegenType.CLIENT;
    }

    public String getName() {
        return "motoko";
    }

    public String getHelp() {
        return "Generates a motoko client.";
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
        languageSpecificPrimitives.add("Array");
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
        typeMapping.put("array", "Array");
        typeMapping.put("map", "HashMap.HashMap");
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
}
