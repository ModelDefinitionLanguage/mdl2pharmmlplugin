package eu.ddmore.converter.mdl2pharmml08;

import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.LinkOption;
import java.nio.file.Path;
import java.nio.file.Paths;

public class FileUtils {

	/**
	 * Generates a URL from a file.  If the relative path is specified then if the dataPath is relative then it is
	 * defined as relative to this path and the URL generated is absolute.  If the dataPath given is absolute then the 
	 * relativePath is ignored.
	 * @param dataPath
	 * @param referencePath
	 * @return
	 */
	public static String generateUrl(Path dataPath, Path referencePath) {
		String retVal = dataPath.toString();
		try {
			if(!dataPath.isAbsolute()){
				// Has reference path so write as an absolute file
				if(referencePath != null){
					dataPath = Paths.get(referencePath.toString(), dataPath.toString());
					if(Files.exists(dataPath, LinkOption.NOFOLLOW_LINKS)){
						retVal = dataPath.toAbsolutePath().normalize().toUri().toURL().toString();
					}
				}
			}
			else {
				// need to make it a URL
				retVal = dataPath.toAbsolutePath().toUri().toURL().toString();
			}
		}
		catch(MalformedURLException e) {
			throw new RuntimeException(e);
		}
		return retVal; 
	}

	/**
	 * Generates a Path from a file.  If the relative path is specified then if the dataPath is relative then it is
	 * defined as relative to this path and the path generated is absolute.  If the dataPath given is absolute then the 
	 * relativePath is ignored.
	 * @param dataPath
	 * @param referencePath
	 * @return
	 */
	public static String generatePath(Path dataPath, Path referencePath) {
	String retVal = dataPath.toString();
		if(!dataPath.isAbsolute()){
			// Has reference path so write as an absolute file
			if(referencePath != null){
				dataPath = Paths.get(referencePath.toString(), dataPath.toString());
				if(Files.exists(dataPath, LinkOption.NOFOLLOW_LINKS)){
					retVal = dataPath.toAbsolutePath().normalize().toString();
				}
			}
		}
		else {
			// need to make it a URL
			retVal = dataPath.toString();
		}
		return retVal; 
	}

}
