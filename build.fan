using build

class Build : BuildPod {

	new make() {
		podName = "afButter"
		summary = "A library that helps ease HTTP requests through a stack of middleware"
		version = Version("0.0.5")

		meta	= [
			"org.name"		: "Alien-Factory",
			"org.uri"		: "http://www.alienfactory.co.uk/",
			"proj.name"		: "Butter",
			"proj.uri"		: "http://www.fantomfactory.org/pods/afButter",
			"vcs.uri"		: "https://bitbucket.org/AlienFactory/afbutter",
			"license.name"	: "BSD 2-Clause License",	
			"repo.private"	: "true"
		]

		depends = [
			"sys 1.0", 
			"inet 1.0", 
			"web 1.0",
			"util 1.0"
		]
		
		srcDirs = [`test/`, `test/oauth/`, `fan/`, `fan/public/`, `fan/public/utils/`, `fan/public/oauth/`, `fan/public/middleware/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true
	}
	
	@Target { help = "Compile to pod file and associated natives" }
	override Void compile() {
		// exclude test code when building the pod
		srcDirs = srcDirs.exclude { it.toStr.startsWith("test/") }
		resDirs = resDirs.exclude { it.toStr.startsWith("res/test/") }
		
		super.compile
		
		// copy src to %FAN_HOME% for F4 debugging
		log.indent
		destDir := Env.cur.homeDir.plus(`src/${podName}/`)
		destDir.delete
		destDir.create		
		`fan/`.toFile.copyInto(destDir)		
		log.info("Copied `fan/` to ${destDir.normalize}")
		log.unindent
	}
}
