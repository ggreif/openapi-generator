package org.openapitools.codegen.motoko;

import org.openapitools.codegen.AbstractOptionsTest;
import org.openapitools.codegen.CodegenConfig;
import org.openapitools.codegen.languages.MotokoClientCodegen;
import org.openapitools.codegen.options.MotokoClientCodegenOptionsProvider;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;

public class MotokoClientCodegenOptionsTest extends AbstractOptionsTest {
    private MotokoClientCodegen codegen = mock(MotokoClientCodegen.class, mockSettings);

    public MotokoClientCodegenOptionsTest() {
        super(new MotokoClientCodegenOptionsProvider());
    }

    @Override
    protected CodegenConfig getCodegenConfig() {
        return codegen;
    }

    @SuppressWarnings("unused")
    @Override
    protected void verifyOptions() {
        // TODO: Complete options using Mockito
        // verify(codegen).someMethod(arguments)
    }
}

