/*
 * generated by Xtext 2.20.0
 */
package dk.sdu.mmmi.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.mmmi.springBoard.SpringBoard
import dk.sdu.mmmi.springBoard.Package
import javax.inject.Inject
import dk.sdu.mmmi.springBoard.Model
import java.util.ArrayList
import java.util.List
import dk.sdu.mmmi.springBoard.Project
import dk.sdu.mmmi.springBoard.Template
import dk.sdu.mmmi.springBoard.Uses
import dk.sdu.mmmi.springBoard.Field

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class SpringBoardGenerator extends AbstractGenerator {

	@Inject extension ServiceGenerator serviceGenerator
	@Inject extension ModelGenerator modelGenerator
	@Inject extension RepositoryGenerator repositoryGenerator
	@Inject extension ControllerGenerator controllerGenerator

	val mavenSrcStructure = "src/main/java/"
	val mavenTestStructure = "src/test/java/"
	List<Model> modelsWithSubClasses = new ArrayList<Model>();

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val model = resource.allContents.filter(SpringBoard).next
		
		// Find templates such that projects can depend on them
		val templates = model.declarations.filter(Template)
		
		
		for (Project springProject : model.declarations.filter(Project)) {
			val projectName = springProject.name
			val packName = createPackageName(springProject.pkg)

			generateSpringProjectStructure(fsa, packName, projectName)
			
			var projectModels = springProject.models.toList
			if (springProject.templates !== null) {
				val usedTemplates = getTemplateList(springProject.templates)
				projectModels = incorporateTemplates(projectModels, usedTemplates)
			}
			
	
			for (Model individualModel : projectModels) {
				if (hasSubclasses(individualModel, springProject)) {
					modelsWithSubClasses.add(individualModel)
				}
			}
	
			// TODO: overwrite service base with new combined model!
			springProject.services.forEach[ element |
				serviceGenerator.createService(fsa, packName, element, projectName); 
				serviceGenerator.createAbstractService(fsa, packName, element, projectName)]
			projectModels.forEach[ element |
				modelGenerator.createModel(element, fsa, packName, hasSubclasses(element, springProject), projectName)
				repositoryGenerator.createRepository(element, fsa, packName, modelsWithSubClasses, projectName)
				(springProject.services.forEach[serviceElement| if (serviceElement.base.name == element.name){
					controllerGenerator.createController(element, serviceElement, fsa, packName, projectName, isASubClass(element))	
				}
					
				])
			
		
			]
		}
		

	}
	
	/**
	 * Takes care of combining templates with the project's own models - when a project makes extensions to templates
	 * this method takes care of appending anything new, and shadow the templates' model if the same name is used
	 */
	def List<Model> incorporateTemplates(List<Model> projectModels, List<Template> templates) {
		var List<Model> incorboratedList = new ArrayList
		val List<Model> allTemplateModels = new ArrayList
		for (t : templates) {
			allTemplateModels.addAll(t.models)
		}
		
		// to avoid java.util.ConcurrentModificationException
		var List<Model> tmToRemove = new ArrayList
		var List<Model> pmToRemove = new ArrayList
		
		// compare all models against each other, in order to determine if any shadowing is necessary
		for (tm : allTemplateModels) {
			for (pm : projectModels) {
				if (pm.base == tm) { // an extension has been declared
					val combinedModel = createCombinedModel(pm, tm)
					incorboratedList.add(combinedModel)
					pmToRemove.add(pm)
					tmToRemove.add(tm)
				}
			}
		}
		allTemplateModels.removeAll(tmToRemove)
		projectModels.removeAll(pmToRemove)
		incorboratedList.addAll(allTemplateModels)
		incorboratedList.addAll(projectModels)
		
		return incorboratedList
	}
		
		def Model createCombinedModel(Model extensionModel, Model templateModel) {
			var Model combinedModel = templateModel
			
			var List<Field> fieldsToRemove = new ArrayList
			var List<Field> fieldsToAdd = new ArrayList
				
			for (ef : extensionModel.fields) {
				for (tf : templateModel.fields) {
					if (ef.name == tf.name) { // shadowing is necessary
						fieldsToRemove.add(tf)
						fieldsToAdd.add(ef)
					} else {
						fieldsToAdd.add(ef)
						System.out.println(ef.name)
					}
				}
			}
			combinedModel.fields.removeAll(fieldsToRemove)
			combinedModel.fields.addAll(fieldsToAdd)
			return combinedModel
		}
		
	// the template list are defined as a recursive rule
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


	def isASubClass(Model element) {
		if (element.inh !== null) {
			return true
		}
		return false
	}

	/**
	 * Important to check for Spring Data API
	 * https://blog.netgloo.com/2014/12/18/handling-entities-inheritance-with-spring-data-jpa/
	 */
	def hasSubclasses(Model element, Project springProject) {
		for (Model m : springProject.models.filter(Model)) {
			if(m.inh !== null && m.inh.base.name == element.name) return true
		}
		return false
	}

	def generateSpringProjectStructure(IFileSystemAccess2 fsa, String packName, String projectName) {
		fsa.generateFile(projectName + "/pom.xml", generatePom(packName))
		fsa.generateFile(projectName + "/" + mavenSrcStructure + packName.replace('.', '/') + "/DemoApplication.java",
			generateSource(packName))
		fsa.generateFile(projectName + "/" + mavenTestStructure + packName.replace('.', '/') + "/DemoApplicationTests.java",
			generateTest(packName))
		fsa.generateFile(projectName + "/" + "src/main/resources/application.properties", generateProperties())
	}

	/**
	 * TODO: should probably be configurable instead of hardcoded database / 
	 * OR: people should make this themselves
	 */
	def CharSequence generateProperties() '''
	# H2
	spring.datasource.url=jdbc:h2:mem:jpadb 
	spring.datasource.username=sa
	spring.datasource.password=mypass
	spring.datasource.driverClassName=org.h2.Driver
	spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
	spring.jpa.generate-ddl=true
	spring.jpa.hibernate.ddl-auto=create
	'''

	def CharSequence generateTest(String packName) '''
	package �packName�;
	import org.junit.jupiter.api.Test;
	import org.springframework.boot.test.context.SpringBootTest;
	
	@SpringBootTest
	class DemoApplicationTests {
		
	  @Test
	  void contextLoads() {
	  }
	  
	}
	'''

	def createPackageName(Package pack) {
		var packIter = pack
		var name = packIter.name

		while (packIter.next !== null) {
			packIter = packIter.next
			name += ('.' + packIter.name)
		}
		return name
	}

	/**
	 * TODO: perhaps include some way of configuring this?
	 */
	def CharSequence generatePom(String packName) '''
		<?xml version="1.0" encoding="UTF-8"?>
		<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
		  <modelVersion>4.0.0</modelVersion>
		  <parent>
		    <groupId>org.springframework.boot</groupId>
		    <artifactId>spring-boot-starter-parent</artifactId>
		    <version>2.2.6.RELEASE</version>
		    <relativePath/> <!-- lookup parent from repository -->
		  </parent>
		  
		  <groupId>�packName�</groupId>
		  <artifactId>demo</artifactId>
		  <version>0.0.1-SNAPSHOT</version>
		  <name>demo</name>
		  <description>Demo project for Spring Boot</description>
		  
		  <properties>
		    <java.version>11</java.version>
		  </properties>
		  
		  <dependencies>
		    <dependency>
		      <groupId>org.springframework.boot</groupId>
		      <artifactId>spring-boot-starter-web</artifactId>
		    </dependency>
		    
		    <dependency>
		      <groupId>org.springframework.boot</groupId>
		      <artifactId>spring-boot-starter-test</artifactId>
		      <scope>test</scope>
		      <exclusions>
		        <exclusion>
		          <groupId>org.junit.vintage</groupId>
		          <artifactId>junit-vintage-engine</artifactId>
		        </exclusion>
		      </exclusions>
		    </dependency>
		    
		    <dependency>
		        <groupId>org.springframework.boot</groupId>
		        <artifactId>spring-boot-starter-data-jpa</artifactId>
		    </dependency>
		     
		    <dependency>
		        <groupId>com.h2database</groupId>
		        <artifactId>h2</artifactId>
		        <scope>runtime</scope> 
		    </dependency>
		  </dependencies>
		  <build>
		    <plugins>
		      <plugin>
		        <groupId>org.springframework.boot</groupId>
		        <artifactId>spring-boot-maven-plugin</artifactId>
		      </plugin>
		    </plugins>
		  </build>
		</project>
	'''

	def CharSequence generateSource(String packName) '''
		package �packName�;
		
		import org.springframework.boot.SpringApplication;
		import org.springframework.boot.autoconfigure.SpringBootApplication;
		
		@SpringBootApplication
		public class DemoApplication {
		  public static void main(String[] args) {
		    SpringApplication.run(DemoApplication.class, args);
		  }
		}
	'''
}
