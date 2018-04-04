package eu.ddmore.libpharmml;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.fail;

import java.io.IOException;
import java.io.InputStream;
import java.net.URL;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.junit.Test;

import foundation.ddmore.pharmml08.ILibPharmML;
import foundation.ddmore.pharmml08.IPharmMLResource;
import foundation.ddmore.pharmml08.IValidationError;
import foundation.ddmore.pharmml08.IValidationReport;
import foundation.ddmore.pharmml08.PharmMlFactory;

/**
 * Tests integration with libPharmML
 */
public class LibPharmMLIntegrationTest {

    private static final Logger LOG = Logger.getLogger(LibPharmMLIntegrationTest.class);

    @Test
    public void shouldValidatePharmMLResource() throws IOException {
        ILibPharmML libPharmML = PharmMlFactory.getInstance().createLibPharmML();
        InputStream in = null;
        
        String modelFile = "file:src/eu/ddmore/libpharmml/UseCase1.xml";
        URL url = null;
        try {
            url = new URL(modelFile);
            in = url.openStream();
            IPharmMLResource res = libPharmML.createDomFromResource(in);
            IValidationReport rpt = res.getCreationReport();
            if (rpt.isValid()) {
                LOG.info(modelFile + " is valid");
            } else {
                for (int i = 1; i <= rpt.numErrors(); i++) {
                    IValidationError err = rpt.getError(i);
                    LOG.info("Error " + (i) + ": " + err.getErrorMsg());
                }
                fail("The validation failed");
            }
        } finally {
            IOUtils.closeQuietly(in);
        }
    }

    @Test
    public void shouldInValidatePharmMLResource() throws IOException {
        ILibPharmML libPharmML = PharmMlFactory.getInstance().createLibPharmML();
        String modelFile = "file:src/eu/ddmore/libpharmml/InvalidUseCase1.xml";
        URL url = null;
            url = new URL(modelFile);
            try(InputStream in = url.openStream()){
            IPharmMLResource res = libPharmML.createDomFromResource(in);
            IValidationReport rpt = res.getCreationReport();
            assertFalse("expect invalid", rpt.isValid());
            assertEquals(2, rpt.numErrors());
//                for (int i = 1; i <= rpt.numErrors(); i++) {
//                    IValidationError err = rpt.getError(i);
//                    LOG.info("Error " + (i) + ": " + err.getErrorMsg());
//                }
//                fail("The validation failed");
            }
    }
}
