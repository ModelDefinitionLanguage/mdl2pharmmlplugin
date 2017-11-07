package eu.ddmore.converter.mdl2pharmml08

import com.google.inject.Inject
import eu.ddmore.mdl.scoping.MdlImportURIGlobalScopeProvider
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream
import java.util.Map
import org.apache.commons.io.IOUtils
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.LazyStringInputStream

/**
 * Provides parsing functionality for unit test.
 * This class takes care of initialising the parser and makes sure that the definitions
 * can be loaded from the definitions bundle.
 * Not that the handing of the definitions behaves differently depending if the tests are run
 * from maven or not. 
 */

class MdlTestHelper<T extends EObject> {
	@Inject
    private XtextResourceSet resourceSet;

	def parse(CharSequence p) {
		parse(getAsStream(p), resourceSet)
	}
	
	def parse(CharSequence p, XtextResourceSet rs) {
		parse(getAsStream(p), rs)
	}
	
	def private InputStream getAsStream(CharSequence text) {
		return new LazyStringInputStream(if(text === null) "" else text.toString());
	}

    /**
     * Parses an input stream and returns the resulting object tree root element.
     * @param in Input Stream
     * @return Root model object
     * @throws IOException When and I/O related parser error occurs
     */
    def T parse(InputStream in, XtextResourceSet rs) throws IOException {
        registerURIMappingsForImplicitImports(rs);
    	val resource = rs.createResource(URI.createURI("sample.mdl"))
        resource.load(in, rs.getLoadOptions());
        return resource.getContents().get(0) as T;
    }
 
    def private static void registerURIMappingsForImplicitImports(XtextResourceSet resourceSet) {
        val uriConverter = resourceSet.getURIConverter();
        val uriMap = uriConverter.getURIMap();
        registerPlatformToFileURIMapping(MdlImportURIGlobalScopeProvider.HEADER_URI, uriMap);
    }
 
    def private static void registerPlatformToFileURIMapping(URI uri, Map<URI, URI> uriMap) {
		var fileURI = createFileFromBundle(uri)
		if(fileURI === null){
			// as a fallback use the original uri 
			fileURI = uri
		}
        uriMap.put(uri, fileURI);
        
    }
 
 	def private static URI createFileFromBundle(URI uri) {
		var path = uri.path().replace("/plugin/", ""); // Eclipse RCP platform URL to a plugin resource starts with "/plugin/" so strip this off 
		path = path.substring(path.indexOf("/")+1); // This skips past the plugin name, i.e. eu.ddmore.mdl.definitions/
 		var url = MdlTestHelper.classLoader.getResource(path)
 		if(url !== null){
//			System.out.println("jar url=" + url.toString())
			val in = url.openStream
			val tmpFile = File.createTempFile("mdlLib", ".mlib")
//			System.out.println("tmpfile =" + tmpFile.absolutePath)
			val out = new FileOutputStream(tmpFile)
			IOUtils.copy(in, out)
			in.close
			out.close
			tmpFile.deleteOnExit
			URI.createFileURI(tmpFile.absolutePath)
		}
		else{
			null
		}
	}
}