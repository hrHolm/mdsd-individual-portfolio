/*
 * generated by Xtext 2.20.0
 */
package dk.sdu.mmmi.scoping

import org.eclipse.xtext.scoping.IScope
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.EcoreUtil2
import java.util.ArrayList
import org.eclipse.xtext.scoping.Scopes
import dk.sdu.mmmi.springBoard.Field
import dk.sdu.mmmi.springBoard.SpringBoardPackage.Literals
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.Method
import dk.sdu.mmmi.springBoard.Model
import dk.sdu.mmmi.springBoard.SpringBoard
import dk.sdu.mmmi.springBoard.Template
import java.util.List


/**
 * This class contains custom scoping description.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#scoping
 * on how and when to use it.
 */
class SpringBoardScopeProvider extends AbstractSpringBoardScopeProvider {

	override IScope getScope(EObject context, EReference reference) {
		switch reference {
			case reference == Literals.COMP__RIGHT: {
				return scopeForTypeReference(context, reference)
			}
			case reference == Literals.MODEL__BASE: {
				return scopeForModelReference(context, reference)
			}
			case reference == Literals.MODEL_TYPE__BASE: {
				return scopeForModelReference(context, reference)
			}
			case reference == Literals.SERVICE__BASE: {
				return scopeForModelReference(context, reference)
			}
		}
		return super.getScope(context, reference)
	}

	/**
	 * Provides scope for all templates (called candidates) and the project's own model definitions (via super.getScope)
	 * Note: even templates not necessarily imported gets visible, and therefore needs a corresponding validity check
	 */ 
	def protected IScope scopeForModelReference(EObject context, EReference reference) {
		val springBoard = EcoreUtil2.getContainerOfType(context, SpringBoard)
		val candidates = new ArrayList<Model>

		var List<Template> templates = springBoard.declarations.filter(Template).toList
		for (Template t : templates) {
			candidates.addAll(t.models)
		}			
		return Scopes.scopeFor(candidates, super.getScope(context, reference))
	}

	def protected IScope scopeForTypeReference(EObject context, EReference reference) {
		var methods = EcoreUtil2.getContainerOfType(context, Method);
		val candidates = new ArrayList<Field>

		var type = methods.type;

		if (type instanceof ListOf) {
			type = (type as ListOf).type
		}
		if (type instanceof ModelType) {
			var model = (type as ModelType)
			candidates.addAll(model.base.getFields.filter(Field))
			if (model.base.inh !== null) {
				candidates.addAll(model.base.inh.base.getFields.filter(Field))
			}
		} else {
			return super.getScope(context, reference)
		}
		return Scopes.scopeFor(candidates)
	}

}
