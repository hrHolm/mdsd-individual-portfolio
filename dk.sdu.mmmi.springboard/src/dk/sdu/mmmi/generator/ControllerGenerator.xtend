package dk.sdu.mmmi.generator

import org.eclipse.xtext.generator.IFileSystemAccess2
import dk.sdu.mmmi.springBoard.Model
import dk.sdu.mmmi.springBoard.Str
import dk.sdu.mmmi.springBoard.Int
import dk.sdu.mmmi.springBoard.Dt
import dk.sdu.mmmi.springBoard.Lon
import dk.sdu.mmmi.springBoard.Bool
import dk.sdu.mmmi.springBoard.ModelType
import dk.sdu.mmmi.springBoard.ListOf
import dk.sdu.mmmi.springBoard.Identifier
import dk.sdu.mmmi.springBoard.Service
import dk.sdu.mmmi.springBoard.CRUDActions
import dk.sdu.mmmi.springBoard.Args
import dk.sdu.mmmi.springBoard.Post
import dk.sdu.mmmi.springBoard.Get
import dk.sdu.mmmi.springBoard.Put
import dk.sdu.mmmi.springBoard.Delete
import dk.sdu.mmmi.springBoard.Local

class ControllerGenerator {

	val mavenSrcStructure = "src/main/java/"

	def CharSequence generateController(Service service, String packName, boolean isASubClass) {
		'''
package «packName».controllers;
import «packName».models.*;
import org.springframework.web.bind.annotation.*;
import «packName».services.I«service.base.name»;
import javax.validation.Valid;
import java.util.List;
import java.time.LocalDateTime;

@RestController
public class «service.base.name»Controller {
	
	private I«service.base.name» «service.base.name.toFirstLower»Service;
	
	public «service.base.name»Controller(I«service.base.name» «service.base.name.toFirstLower»Service) {
	    this.«service.base.name.toFirstLower»Service =  «service.base.name.toFirstLower»Service;
	}
	
	«IF service.crud !== null»
	«generateCRUDMethods(service)»
	«ENDIF»
	«generateServiceMethods(service)»
}
'''
	}

	def createController(Service service, IFileSystemAccess2 fsa, String packName, String projectName, boolean isASubClass) {
		fsa.generateFile(projectName + "/" + mavenSrcStructure + packName.replace('.', '/') + "/controllers/" + service.base.name + "Controller.java",
			generateController(service, packName, isASubClass)
		)
	}

	def generateCRUDMethods(Service service) {
		'''
			«FOR a : service.crud.act»
				«IF a == CRUDActions.C»
					@PostMapping("/api/«service.base.name.toLowerCase»")
					public «service.base.name» create«service.base.name»(@Valid @RequestBody «service.base.name» «service.base.name.toFirstLower») {
						return «service.base.name.toFirstLower»Service.create(«service.base.name.toFirstLower»);
					}
					
				«ENDIF»
				«IF a == CRUDActions.R»
					@GetMapping("/api/«service.base.name.toLowerCase»/{id}")
					public «service.base.name» find(@PathVariable Long id) {
						return «service.base.name.toFirstLower»Service.find(id);
					}
					
					@GetMapping("/api/«service.base.name.toLowerCase»/all")
					public List<«service.base.name»> findAll() {
						return «service.base.name.toFirstLower»Service.findAll();
					}
					
				«ENDIF»
				«IF a == CRUDActions.U»
					@PutMapping("/api/«service.base.name.toLowerCase»")
					@ResponseBody
					public void update(@RequestBody «service.base.name» «service.base.name.toFirstLower») {
						«service.base.name.toFirstLower»Service.update(«service.base.name.toFirstLower»);
					}
					
				«ENDIF»
				«IF a == CRUDActions.D»
					@DeleteMapping("/api/«service.base.name.toLowerCase»/{id}")
					@ResponseBody
					public void delete(@PathVariable Long id) {
					    «service.base.name.toFirstLower»Service.delete(id);
					}
					
				«ENDIF»
			«ENDFOR»
		'''
	}

	def generateServiceMethods(Service service)'''
			«FOR m : service.methods.filter[m | !(m.req instanceof Local)]»
			@«m.req.showReq»Mapping("/api/«service.base.name.toLowerCase»/«m.name.toLowerCase»")
			«m.type.show» «m.name»(«IF m.inp.args !== null»«m.inp.args.show»«ENDIF»){
				return 	«service.base.name.toFirstLower»Service.«m.name»(«IF m.inp.args !== null»«m.inp.args.showName»«ENDIF»);
			}
			
			«ENDFOR»
			'''
	

	def dispatch CharSequence show(Dt dt) '''LocalDateTime'''

	def dispatch CharSequence show(ListOf lo) '''List<«lo.type.show»>'''

	def dispatch CharSequence show(Str st) '''String'''

	def dispatch CharSequence show(Int in) '''Integer'''

	def dispatch CharSequence show(Lon l) '''Long'''

	def dispatch CharSequence show(Bool b) '''Boolean'''

	def dispatch CharSequence show(Identifier id) '''Long'''

	def dispatch CharSequence show(ModelType m) '''«m.base.name»'''

	def dispatch CharSequence show(Args a) '''@RequestParam «a.type.show» «a.name»«IF a.next !== null», «a.next.show»«ENDIF»'''

	def CharSequence showName(Args a) '''«a.name»«IF a.next!==null», «a.next.showName»«ENDIF»'''
	def CharSequence showType(Args a) '''«a.type.show»'''
	
	def dispatch CharSequence showReq(Post post)'''Post'''
	def dispatch CharSequence showReq(Get get)'''Get'''
	def dispatch CharSequence showReq(Put put)'''Put'''
	def dispatch CharSequence showReq(Delete del)'''Delete'''

}
