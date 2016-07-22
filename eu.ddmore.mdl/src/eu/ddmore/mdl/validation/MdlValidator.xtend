/*
 * generated by Xtext
 */
package eu.ddmore.mdl.validation

import org.eclipse.xtext.validation.ComposedChecks

//import org.eclipse.xtext.validation.Check

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
 @ComposedChecks(validators= #[BlockValidator, 
 								DataFileValidator,
 								UnsupportedFeaturesValidator, MdlCustomValidator,
 								ListValidator,
 								TypeSystemValidator,
 								ValueSelectorValidator, UnsupportedToolSpecificFeaturesValidator,
 								BuiltinFunctionValidator, 
 								MogValidator, 
 								ExpressionValidator, StatementValidator, PropertyValidator ])
class MdlValidator extends AbstractMdlValidator {
	public static val RESERVED_PREFIX = "MDL__" 

	public val static MDLOBJ = 'mdlObj'
	public val static DATAOBJ = 'dataObj'
	public val static TASKOBJ = 'taskObj'
	public val static PARAMOBJ = 'parObj'
	public val static MOGOBJ = 'mogObj'
	public val static DESIGNOBJ = 'designObj'
	public val static PRIOROBJ = 'priorObj'
//	public val static FUNCOBJ = 'funcObj'

	public static val UNUSED_FEATURE = "eu.ddmore.mdl.validation.unused.feature"
	public static val EXPERIMENTAL_FEATURE = "eu.ddmore.mdl.validation.experimental.feature"
	public static val FEATURE_NOT_SUPPORTED_MONOLIX = "eu.ddmore.mdl.validation.unsupported.feature.monolix"
	public static val FEATURE_NOT_SUPPORTED_NONMEM = "eu.ddmore.mdl.validation.unsupported.feature.nonmem"
	public static val FEATURE_NOT_SUPPORTED_PHARMML = "eu.ddmore.mdl.validation.unsupported.feature.pharmml"
	
	// List attribute validation
	public static val UNRECOGNIZED_PROPERTY_ATT  = "eu.ddmore.mdl.validation.UnrecognisedProperty"
	public static val MANDATORY_PROP_MISSING = "eu.ddmore.mdl.validation.MandatoryProputeMissing"
	public static val UNRECOGNIZED_LIST_ATT = "eu.ddmore.mdl.validation.UnrecognisedAttribute"
	public static val MANDATORY_LIST_ATT_MISSING = "eu.ddmore.mdl.validation.MandatoryAttributeMissing"
	public static val MANDATORY_LIST_KEY_ATT_MISSING = "eu.ddmore.mdl.validation.MandatoryKeyAttributeMissing"
	public static val LIST_NOT_ANONYMOUS = "eu.ddmore.mdl.validation.ListNotAnonymous"
	public static val LIST_NOT_NAMED = "eu.ddmore.mdl.validation.ListNotNamed"
	public static val DUPLICATE_ATTRIBUTE_NAME = "eu.ddmore.mdl.validation.DuplicateArgumentName"
	public static val LIST_KEY_VAL_UNRECOGNISED = "eu.ddmore.mdl.validation.Unrecognised.Key.Value"

	// Builtin Function validation
	public static val UNRECOGNIZED_FUNCTION_NAME = "eu.ddmore.mdl.validation.function.named.UnrecognisedFunctionName"
	public static val INCORRECT_NUM_FUNC_ARGS = "eu.ddmore.mdl.validation.function.IncorrectNumArgs"
	public static val MULTIPLE_IDENTICAL_FUNC_ARG = "eu.ddmore.mdl.validation.function.named.MultipleArgs"
	public static val UNRECOGNIZED_FUNCTION_ARGUMENT_NAME = "eu.ddmore.mdl.validation.function.named.UnrecognisedArgName"
	public static val MANDATORY_NAMED_FUNC_ARG_MISSING = "eu.ddmore.mdl.validation.function.named.MandatoryArgMissing"
	public static val INVALID_LHS_FUNC = "eu.ddmore.mdl.validation.function.invalid.lhs"
	
	// Number validation
	public static val NUMBER_BEYOND_PRECISION_RANGE = "eu.ddmore.mdl.validation.number.beyondRange"


	// Validation of syntactic structures
	public static val INCORRECT_STATEMENT_CONTEXT = "eu.ddmore.mdl.validation.IncorrectStatementContext"
	public static val INCORRECT_LIST_CONTEXT = "eu.ddmore.mdl.validation.IncorrectListContext"
	public static val UNDER_DEFINED_IF_ELSE = "eu.ddmore.mdl.validation.UnderDefinedIfElse"
	public static val INVALID_CATEGORY_DEFINITION = "eu.ddmore.mdl.validation.IncompleteCategories"

	// Type validation
	public static val INCOMPATIBLE_TYPES = "eu.ddmore.mdl.validation.IncompatibleTypes"
	public static val MALFORMED_TYPE_SPEC = "eu.ddmore.mdl.validation.MalformedTypeSpec"
	
	// Expressions
	public static val INVALID_CYCLE = "eu.ddmore.mdl.validation.cyclic.ref"
	public static val MATRIX_INCONSISTENT_ROW_SIZE = "eu.ddmore.mdl.validation.matrix.rowsize.notsame"
	public static val UNUSED_VARIABLE = "eu.ddmore.mdl.validation.variable.unused"

	// MOG validation
	public static val MODEL_DATA_MISMATCH = "eu.ddmore.mdl.validation.mog.mismatch_mod_data"
	public static val MCLOBJ_REF_UNRESOLVED = "eu.ddmore.mdl.validation.mog.missingObj"
	public static val MOGOBJ_MALFORMED = "eu.ddmore.mdl.validation.mog.malformed"
	public static val SYMBOL_NOT_INITIALISED = "eu.ddmore.mdl.validation.mog.symbol.uninitialised"

	// Selection value
	public static val DUPLICATE_SELECTION_TEST_VALUE = "eu.ddmore.mdl.validation.selector.testvalue.duplicate"
	public static val DUPLICATE_SELECTION_REF = "eu.ddmore.mdl.validation.selector.ref.duplicate"

	//Custom MDL checks
	public static val INVALID_ENUM_RELATION_OPERATOR = "eu.ddmore.mdl.validation.custom.enum.relation.op"
	public static val DEPENDENT_USE_MISSING = "eu.ddmore.mdl.validation.custom.dep.use.missing"
	public static val INCOMPATIBLE_VARIABLE_REF = "eu.ddmore.mdl.validation.custom.incompatible.var.ref"
	public static val DUPLICATE_UNIQUE_USE_VALUE = "eu.ddmore.mdl.validation.custom.duplicate.use"
	public static val VARIABILITY_LEVELS_MALFORMED = "eu.ddmore.mdl.validation.custom.variability_levels.malformed"
	public static val RESERVED_PREFIX_USED = "eu.ddmore.mdl.validation.custom.reserved.prefix.used"
	public static val RESERVED_WORD_USED = "eu.ddmore.mdl.validation.custom.reserved.word.used"
	public static val OBS_MISSING = "eu.ddmore.mdl.validation.observation.missing"

	// Warnings
	public static val MASKING_PARAM_ASSIGNMENT = "eu.ddmore.mdl.validation.mog.paramValueMasked"
	
}
