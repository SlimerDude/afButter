using build::BuildPod

class Build : BuildPod {

	new make() {
		podName = "afHttpy"
		summary = "Because I gotta!"
		version = Version("0.0.1")

		meta	= [	"org.name"		: "Alien-Factory",
					"org.uri"		: "http://www.alienfactory.co.uk/",
					"proj.name"		: "HTTP-Y",
					"proj.uri"		: "http://www.fantomfactory.org/pods/afHttpy",
					"vcs.uri"		: "https://bitbucket.org/AlienFactory/afhttpy",
					"license.name"	: "BSD 2-Clause License",	
					"repo.private"	: "true"

				]

		depends = ["sys 1.0", "web 1.0"]
		srcDirs = [`test/`, `fan/`, `fan/public/`, `fan/internal/`, `fan/internal/utils/`]
		resDirs = [`doc/`]

		docApi = true
		docSrc = true

	}
}
