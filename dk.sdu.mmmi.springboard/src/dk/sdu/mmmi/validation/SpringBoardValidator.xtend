/*
 * generated by Xtext 2.20.0
 */
package dk.sdu.mmmi.validation

import org.eclipse.xtext.validation.Check
import dk.sdu.mmmi.springBoard.CRUD
import java.util.regex.Pattern
import dk.sdu.mmmi.springBoard.Model
import dk.sdu.mmmi.springBoard.SpringBoardPackage
import dk.sdu.mmmi.springBoard.Identifier
import dk.sdu.mmmi.springBoard.Comp
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.Bool
import dk.sdu.mmmi.springBoard.Str
import dk.sdu.mmmi.springBoard.Gt
import dk.sdu.mmmi.springBoard.Lt
import dk.sdu.mmmi.springBoard.Lteq
import dk.sdu.mmmi.springBoard.Gteq
import org.eclipse.emf.ecore.EObject
import static extension org.eclipse.xtext.EcoreUtil2.*
import dk.sdu.mmmi.springBoard.Project
import java.util.List
import dk.sdu.mmmi.springBoard.Template
import dk.sdu.mmmi.springBoard.Uses
import java.util.ArrayList
import dk.sdu.mmmi.springBoard.Service
import javax.inject.Inject
import dk.sdu.mmmi.springBoard.Exp
import org.eclipse.emf.ecore.EReference
import dk.sdu.mmmi.springBoard.BoolAnd

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class SpringBoardValidator extends AbstractSpringBoardValidator {

	Pattern cPattern = Pattern.compile("([C]).*([C])")
	Pattern rPattern = Pattern.compile("([R]).*([R])")
	Pattern uPattern = Pattern.compile("([U]).*([U])")
	Pattern dPattern = Pattern.compile("([D]).*([D])")

	@Check
	def checkCrudActions(CRUD crud) {

		val matchString = crud.getAct().toString().replace(", ", "")

		val cMatcher = cPattern.matcher(matchString);

		if (cMatcher.find()) {
			error('Only one Create method allowed', crud, null);
		}

		val rMatcher = rPattern.matcher(matchString);

		if (rMatcher.find()) {
			error('Only one Read method allowed', crud, null);
		}

		val uMatcher = uPattern.matcher(matchString);

		if (uMatcher.find()) {
			error('Only one Update method allowed', crud, null);
		}

		val dMatcher = dPattern.matcher(matchString);

		if (dMatcher.find()) {
			error('Only one Delete method allowed', crud, null);
		}

	}

	/**
	 * Inspired by Bettini
	 */
	@Check
	def checkNoCycleInEntityHierarchy(Model model) {
		if (model.inh.base === null)
			return // nothing to check
		val visitedEntities = newHashSet(model)
		var current = model.inh.base
		while (current !== null) {
			if (visitedEntities.contains(current)) {
				error("Cycle in hierarchy of model '" + current.name + "'", SpringBoardPackage.Literals.MODEL__INH)
				return
			}
			visitedEntities.add(current)
			current = current.inh.base
		}
	}

	/**
	 * This check only needs to happen when a model is not an extension - 
	 * this way it is always ensured that an ID is present, since the template's model must have ID's
	 */
	@Check
	def checkOnlySingleIdForModel(Model model) {
		if (model.base === null) {
			if (model.inh !== null) {
				if (!model.fields.filter[f|f.type instanceof Identifier].empty) {
					error("Subclasses must not have an ID field.", SpringBoardPackage.Literals.MODEL__FIELDS)
				}
			} else {
				if (model.fields.filter[f|f.type instanceof Identifier].size != 1) {
					error("A model must have a single ID field.", SpringBoardPackage.Literals.MODEL__NAME)
				}
			}
		}
	}

	@Check
	def checkComparisonOperator(Comp comp) {
		if (comp.left.type.class !== comp.right.type.class) {
			error("Type mismatch", comp, SpringBoardPackage.Literals.COMP__RIGHT)
		}
		switch comp.left.type {
			ModelType,
			ListOf,
			Bool,
			Str,
			Identifier:
				switch comp.op {
					Gt,
					Lt,
					Lteq,
					Gteq: error("Invalid operator for this type", comp, SpringBoardPackage.Literals.COMP__OP)
					default: ''
				}
			default:
				''
		}
	}
	
	/* ------------- Template Validations ------------- */
	
	/**
	 * Make sure unique naming is done when importing templates
	 */
	@Check
	def checkUniqueNamingFromImportedTemplates(Model model) {
		val contextProject = (model as EObject).getContainerOfType(Project)
		if (contextProject.templates !== null && model.name !== null) {
			for (t : contextProject.templates.templateList) {
				for (m : t.models) {
					if (m.name.equalsIgnoreCase(model.name)) {
						error('''The name: �model.name� is already used by the imported template: �t.name�''', SpringBoardPackage.Literals.MODEL__NAME)
					}
				}
			}
		}
	}
	
	/**
	 * Make sure unique naming is done when importing templates
	 */
	@Check
	def checkUniqueNamingFromImportedTemplates(Service service) {
		val contextProject = (service as EObject).getContainerOfType(Project)
		if (contextProject.templates !== null && !service.isExtension) {
			for (t : contextProject.templates.templateList) {
				for (m : t.models) {
					if (m.name.equalsIgnoreCase(service.base.name)) {
						System.out.println("what")
						error('''The name: �service.base.name� is already used by the imported template: �t.name�''', SpringBoardPackage.Literals.SERVICE__BASE)
					}
				}
			}
		}
	}
	
	/**
	 * Checks if the necessary templates have been imported when extending a model
	 */ 
	@Check
	def checkTemplateImport(Model model) {
		if (model.base !== null && !model.base.isImported(model)) {
			error('''The model: �model.base.name� has not been imported from a template.''', SpringBoardPackage.Literals.MODEL__BASE)
		}
		
	}
	
	/**
	 * Checks if the necessary templates have been imported when extending a model
	 */ 
	@Check
	def checkTemplateImport(Service service) {
		if (service.extension && !service.base.isImported(service)) {
			error('''The model: �service.base.name� has not been imported from a template.''', SpringBoardPackage.Literals.SERVICE__BASE)
		}
		
	}
	
	/**
	 * Checks if the necessary models are accessible if a model is used as a type
	 */ 
	@Check
	def checkIfModelIsAccessableAsType(ModelType modelType) {
		val contextProject = (modelType as EObject).getContainerOfType(Project)
		if (modelType.base !== null && !contextProject.models.contains(modelType.base) && !modelType.base.isImported(modelType)) {
			error('''The model: �modelType.base.name� is not accessable.''', SpringBoardPackage.Literals.MODEL_TYPE__BASE)
		}
	}
	
	protected def boolean isImported(Model base, EObject context) {
		val contextProject = context.getContainerOfType(Project)
		if (contextProject.templates === null) { // null-safety
			return false
		}
		for (t : contextProject.templates.templateList) {
			if (t.models.contains(base)) {
				return true
			}
		}
		return false
	}
	
	def List<Template> getTemplateList(Uses uses) {
		var usesIter = uses
		var List<Template> templateList = new ArrayList
		templateList.add(usesIter.base)

		while (usesIter.next !== null) {
			usesIter = usesIter.next
			templateList.add(usesIter.base)
		}
		return templateList
	}
	
	/* ------------- Logic Validations ------------- */
	// TODO: requirement must refer to the field by name, either on right or left side, but not both
	
	@Inject extension LogicTyping logicTyping
	
	def private ExpressionsType getTypeAndCheckNotNull(Exp exp, EReference reference) {
		var type = exp.typeFor
		if (type == null)
			error("null type", reference, "Type Mismatch")
		return type;
	}
	
	def private checkExpectedType(Exp exp,
		ExpressionsType expectedType, EReference reference) {
		val actualType = getTypeAndCheckNotNull(exp, reference)
		if (actualType != expectedType)
		error("expected " + expectedType +
		" type, but was " + actualType,
		reference, "Type Mismatch")
	}
	/* TODO chapter 8 side 185
	@Check 
	def checkType(BoolAnd and) {
		checkExpectedType(and.left, ExpressionsType.BOOL_TYPE,
		SpringBoardPackage.Literals.BOOL_AND__LEFT)
		checkExpectedBoolean(and.right,
		ExpressionsPackage.Literals.AND__RIGHT)
	}
	*/
	
	
}
