
internal class TestFollowRedirectsMiddleware : ButterTest {
	
	FollowRedirectsMiddleware? mw
	
	override Void setup() {
		mw = FollowRedirectsMiddleware()
	}
	
	Void testPassThroughOn200() {
		res := ButterResponse(200, "", [:], "")
		end	:= MockTerminator([res])
		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/`)
		verifyEq(res.statusCode, 200)
	}

	Void testPassThroughWhenNoLocation() {
		res := ButterResponse(301, "", [:], "")
		end	:= MockTerminator([res])
		mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/`)
		verifyEq(res.statusCode, 301)
	}
	
	Void testPassThroughWhenTurnedOff() {
		mw.followRedirects = false
		end	:= MockTerminator([
			ButterResponse(301, "", ["Location":"/301"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/`)
		verifyEq(res.statusCode, 301)
		verifyEq(res.headers.location, `/301`)
	}

	Void testMultipleRedirects() {
		mw.tooManyRedirects	= 3
		end	:= MockTerminator([
			ButterResponse(301, "", ["Location":"/301-1"], ""), 
			ButterResponse(301, "", ["Location":"/301-2"], ""), 
			ButterResponse(301, "", ["Location":"/301-3"], ""), 
			ButterResponse(200, "Groovy", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.uri, `/301-3`)
		verifyEq(res.statusCode, 200)
		verifyEq(res.statusMsg, "Groovy")
	}

	Void testErrOnTooManyRedirects() {
		mw.tooManyRedirects	= 3
		end	:= MockTerminator([
			ButterResponse(301, "", ["Location":"/301-1"], ""), 
			ButterResponse(301, "", ["Location":"/301-2"], ""), 
			ButterResponse(301, "", ["Location":"/301-3"], ""), 
			ButterResponse(301, "", ["Location":"/301-4"], ""), 
			ButterResponse(200, "", [:], "")
		])
		verifyErrTypeAndMsg(ButterErr#, ErrMsgs.tooManyRedirects(3)) {
			res := mw.sendRequest(end, ButterRequest(`/`))
		}
	}

	Void test301Get() {
		end	:= MockTerminator([
			ButterResponse(301, "", ["Location":"/301"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/301`)
		verifyEq(res.statusCode, 200)
	}

	Void test301Post() {
		end	:= MockTerminator([
			ButterResponse(301, "", ["Location":"/301"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "POST")
		verifyEq(end.req.uri, `/301`)
		verifyEq(res.statusCode, 200)
	}
	
	Void test302GetHttp10() {
		end	:= MockTerminator([
			ButterResponse(302, "", ["Location":"/302"], "") { it.version = Butter.http10 }, 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/302`)
		verifyEq(res.statusCode, 200)
	}

	Void test302PostHttp10() {
		end	:= MockTerminator([
			ButterResponse(302, "", ["Location":"/302"], "") { it.version = Butter.http10 }, 
			ButterResponse(200, "", [:], "") 
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/302`)
		verifyEq(res.statusCode, 200)
	}

	Void test302GetHttp11() {
		end	:= MockTerminator([
			ButterResponse(302, "", ["Location":"/302"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/302`)
		verifyEq(res.statusCode, 200)
	}

	Void test302PostHttp11() {
		end	:= MockTerminator([
			ButterResponse(302, "", ["Location":"/302"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "POST")
		verifyEq(end.req.uri, `/302`)
		verifyEq(res.statusCode, 200)
	}
	
	Void test303Get() {
		end	:= MockTerminator([
			ButterResponse(303, "", ["Location":"/303"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/303`)
		verifyEq(res.statusCode, 200)
	}

	Void test303Post() {
		end	:= MockTerminator([
			ButterResponse(303, "", ["Location":"/303"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/303`)
		verifyEq(res.statusCode, 200)
	}

	Void test307Get() {
		end	:= MockTerminator([
			ButterResponse(307, "", ["Location":"/307"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`))
		verifyEq(end.req.method, "GET")
		verifyEq(end.req.uri, `/307`)
		verifyEq(res.statusCode, 200)
	}

	Void test307Post() {
		end	:= MockTerminator([
			ButterResponse(307, "", ["Location":"/307"], ""), 
			ButterResponse(200, "", [:], "")
		])
		res := mw.sendRequest(end, ButterRequest(`/`) { it.method = "post" })
		verifyEq(end.req.method, "POST")
		verifyEq(end.req.uri, `/307`)
		verifyEq(res.statusCode, 200)
	}
	
}