package eu.ddmore.converter.mdl2pharmml08;

import java.nio.file.Path;
import java.nio.file.Paths;

import com.google.common.base.Preconditions;

public class FileUtils {

//	/**
//	 * Generates a URL from a file.  If the relative path is specified then if the dataPath is relative then it is
//	 * defined as relative to this path and the URL generated is absolute.  If the dataPath given is absolute then the 
//	 * relativePath is ignored.
//	 * @param dataPath
//	 * @param referencePath
//	 * @return
//	 */
//	public static String generateUrl(Path dataPath, Path referencePath) {
//		String retVal = dataPath.toString();
//		try {
//			if(!dataPath.isAbsolute()){
//				// Has reference path so write as an absolute file
//				if(referencePath != null){
//					dataPath = Paths.get(referencePath.toString(), dataPath.toString());
//					if(Files.exists(dataPath, LinkOption.NOFOLLOW_LINKS)){
//						retVal = dataPath.toAbsolutePath().normalize().toUri().toURL().toString();
//					}
//				}
//			}
//			else {
//				// need to make it a URL
//				retVal = dataPath.toAbsolutePath().toUri().toURL().toString();
//			}
//		}
//		catch(MalformedURLException e) {
//			throw new RuntimeException(e);
//		}
//		return retVal; 
//	}
//
	public static Path generateDataPath(boolean makeAbs, Path mdlPath, Path dataPath, Path pharmMLPath) {
		Preconditions.checkArgument(dataPath != null, "Data path must not be set");
		
		Path retVal = dataPath;
		if(!dataPath.isAbsolute() && makeAbs) {
			if(mdlPath != null) {
				Preconditions.checkArgument(mdlPath.isAbsolute(), "MDL path must be absolute %s", mdlPath.toString());
				Path absDataPath = Paths.get(mdlPath.getParent().toString(), dataPath.toString());
				retVal = absDataPath.normalize();
			}
			else {
				retVal = dataPath.toAbsolutePath();
			}
		}
		else if(!dataPath.isAbsolute() && mdlPath != null && pharmMLPath != null) {
			Path relDataPath = FileUtils.makeNewRelativeDataPath(mdlPath, dataPath, pharmMLPath);
			retVal = relDataPath;
		}
		return retVal;
	}
	
	/**
	 * Generates a relative data path for the new pharmml location based on the original mdl location
	 * @param mdlPath the path of the MDL file, which must be absolute
	 * @param dataPath the path of the data file that must be relative. 
	 * @param pharmmlPath the path of the PharmML file, which must be absolute
	 * @return
	 */
	public static Path makeNewRelativeDataPath(Path mdlPath, Path dataPath, Path pharmMLPath) {
		Preconditions.checkArgument(mdlPath.isAbsolute(), "Mdl file path must be absolute: %s", mdlPath);
		Preconditions.checkArgument(!dataPath.isAbsolute(), "Data path should not be absolute %s", dataPath);
		Preconditions.checkArgument(pharmMLPath.isAbsolute(), "PharmML file path must be absolute: %s", pharmMLPath);
		Path pharmMLBasePath = pharmMLPath.getParent();
		
		Path absDataPath = Paths.get(mdlPath.toAbsolutePath().getParent().toString(), dataPath.toString()).normalize();
		Path relNewDataPath = pharmMLBasePath.relativize(absDataPath);
		return relNewDataPath;
	}

}
