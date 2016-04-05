/*
* generated by Xtext
*/
package eu.ddmore.mdl.ui.labeling

import com.google.inject.Inject
import eu.ddmore.mdl.mdl.AnonymousListStatement
import eu.ddmore.mdl.mdl.BlockStatement
import eu.ddmore.mdl.mdl.EquationDefinition
import eu.ddmore.mdl.mdl.ListDefinition
import eu.ddmore.mdl.mdl.Mcl
import eu.ddmore.mdl.mdl.MclObject
import eu.ddmore.mdl.mdl.RandomVariableDefinition
import eu.ddmore.mdl.mdl.TransformedDefinition
import eu.ddmore.mdl.mdl.ValuePair
import eu.ddmore.mdl.type.TypeSystemProvider
import eu.ddmore.mdl.utils.BlockUtils
import eu.ddmore.mdl.validation.MdlValidator
import eu.ddmore.mdllib.mdllib.SymbolDefinition
import org.eclipse.emf.edit.ui.provider.AdapterFactoryLabelProvider
import org.eclipse.xtext.ui.IImageHelper
import org.eclipse.xtext.ui.label.DefaultEObjectLabelProvider

import static eu.ddmore.mdl.ui.outline.Images.*

/**
 * Provides labels for a EObjects.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#labelProvider
 */
class MdlLabelProvider extends DefaultEObjectLabelProvider {

	extension BlockUtils bu = new BlockUtils
	extension TypeSystemProvider tsu = new TypeSystemProvider

	@Inject
	new(AdapterFactoryLabelProvider delegate) {
		super(delegate);
	}

	def text(TransformedDefinition ele) {
		ele.transform.name + '(' + ele.name + ')' + ele.printType
	}

	private def printType(SymbolDefinition it){
		"::" + typeFor?.typeName ?: "<error!>"
	}

	def text(EquationDefinition ele) {
		ele.name + ele.printType()
	}

	def text(RandomVariableDefinition ele) {
		ele.name + ele.printType()
	}

	def text(ListDefinition ele) {
		ele.name + ele.printType()
	}

	def text(BlockStatement it) {
		blkId?.name ?: '<undefined>'
	}

	@Inject IImageHelper imageHelper;

 	def image(Mcl e) {
        return imageHelper.getImage(getPath(MDL));
    }
    
	def image(MclObject e) {
		return switch(e?.mdlObjType){
			case null: null
			case MdlValidator::MDLOBJ: imageHelper.getImage(getPath(MODEL_OBJ))
			case MdlValidator::DATAOBJ: imageHelper.getImage(getPath(DATA_OBJ))
			case MdlValidator::PARAMOBJ: imageHelper.getImage(getPath(PARAMETER_OBJ))
			case MdlValidator::TASKOBJ: imageHelper.getImage(getPath(TASK_OBJ))
			case MdlValidator::MOGOBJ: imageHelper.getImage(getPath(MOG_OBJ))
			case MdlValidator::DESIGNOBJ: imageHelper.getImage(getPath(DESIGN_OBJ))
			default: null			
		}
    }

	def image(SymbolDefinition s){
		return imageHelper.getImage(getPath(SYMBOL_DECLARATION));
	}

	def image(ValuePair s){
		return imageHelper.getImage(getPath(ATTRIBUTE));
	}

	def image(AnonymousListStatement s){
		return imageHelper.getImage(getPath(SYMBOL_DECLARATION));
	}

	def image(BlockStatement s){
		return imageHelper.getImage(getPath(BLOCK_STMT));
	}
}