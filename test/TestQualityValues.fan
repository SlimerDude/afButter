
class TestQualityValues : Test {
	
	Void testParseOne() {
		qvs	:= QualityValues("gzip")
		
		verifyEq(qvs.size, 1)
		verifyEq(qvs["gzip"], 1f)
		verifyEq(qvs["deflate"], 0f)
		verifyEq(qvs.accepts("gzip"), true)
		verifyEq(qvs.accepts("deflate"), false)
	}

	Void testParseMany() {
		qvs	:= QualityValues("gzip, deflate")
		
		verifyEq(qvs.size, 2)
		verifyEq(qvs["gzip"], 1f)
		verifyEq(qvs["deflate"], 1f)
		verifyEq(qvs.accepts("gzip"), true)
		verifyEq(qvs.accepts("deflate"), true)
		verifyEq(qvs.accepts("wotever"), false)
	}

	Void testParseQValues() {
		qvs	:= QualityValues("audio/*; q=0.2, audio/basic")
		
		verifyEq(qvs.size, 2)
		verifyEq(qvs["audio/*"], 0.2f)
		verifyEq(qvs["audio/basic"], 1f)
		verifyEq(qvs.accepts("audio/*"), true)
		verifyEq(qvs.accepts("audio/basic"), true)
		verifyEq(qvs.accepts("wotever"), false)
	}

	Void testParseQValues2() {
		qvs	:= QualityValues("gzip;q=1.0, identity; q=0.5, *;q=0")
		
		verifyEq(qvs.size, 3)
		verifyEq(qvs["gzip"], 1.0f)
		verifyEq(qvs["identity"], 0.5f)
		verifyEq(qvs["*"], 0.0f)
		verifyEq(qvs.accepts("gzip"), true)
		verifyEq(qvs.accepts("identity"), true)
		verifyEq(qvs.accepts("*"), false)
		verifyEq(qvs.accepts("wotever"), false)
	}
	
	Void testParseErr1() {
		try {
			qvs	:= QualityValues("gzip;q=1.0;q=0")
			fail
		} catch (ParseErr pe) { }
	}
	
	Void testParseErr2() {
		try {
			qvs	:= QualityValues("gzip;qs=0.0")
			fail
		} catch (ParseErr pe) { }
	}
	
	Void testParseErr3() {
		try {
			qvs	:= QualityValues("gzip;q=none")
			fail
		} catch (ParseErr pe) { }
	}
	
	Void testParseErr4() {
		try {
			qvs	:= QualityValues("gzip;q=-0.3")
			fail
		} catch (ParseErr pe) { }
	}
	
	Void testParseErr5() {
		try {
			qvs	:= QualityValues("gzip;q=69")
			fail
		} catch (ParseErr pe) { }
	}
	
	Void testParseReturnsNull() {
		qvs	:= QualityValues("gzip;q=69", false)
		verifyNull(qvs)
	}
	
	Void testToStr() {
		qvs	:= QualityValues("*;q=0, identity; q=0.5, deflate; q=0.256, gzip;q=1.0")
		verifyEq(qvs.toStr, "gzip, identity;q=0.5, deflate;q=0.256, *;q=0")
	}
	
	Void testContainsMediaWildCards() {
		qvs	:= QualityValues("*")
		verifyEq(qvs.contains("text"), true)
	}

	Void testContainsSubWildCards() {
		qvs	:= QualityValues("text/*")
		verifyEq(qvs.contains("text/*"), true)
		verifyEq(qvs.contains("text/html"), true)
		verifyEq(qvs.contains("text"), false)
		verifyEq(qvs.contains("app/html"), false)
	}
	
	Void testAcceptMediaWildCards() {
		qvs	:= QualityValues("*")
		verifyEq(qvs.accepts("text"), true)

		qvs	= QualityValues("*; q=0")
		verifyEq(qvs.accepts("text"), false)
	}

	Void testAcceptSubWildCards() {
		qvs	:= QualityValues("text/*")
		verifyEq(qvs.accepts("text/*"), true)
		verifyEq(qvs.accepts("text/html"), true)
		verifyEq(qvs.accepts("text"), false)
		verifyEq(qvs.accepts("app/html"), false)

		qvs	= QualityValues("app/*, text/*; q=0")
		verifyEq(qvs.accepts("text/*"), false)
		verifyEq(qvs.accepts("text/html"), false)
		verifyEq(qvs.accepts("text"), false)
		verifyEq(qvs.accepts("app"), false)
		verifyEq(qvs.accepts("app/html"), true)

		qvs	= QualityValues("*, text/*; q=0")	// the "*;q=1.0" means everything is accepted!
		verifyEq(qvs.accepts("text/*"), true)
		verifyEq(qvs.accepts("text/html"), true)
		verifyEq(qvs.accepts("text"), true)
		verifyEq(qvs.accepts("app/html"), true)
	}
}
