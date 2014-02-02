
internal class TestErrOn4xxMiddleware : ButterTest {
	
	Void testPassThroughOn200() {
		mw	:= ErrOn4xxMiddleware()
		res := ButterResponse(200, "", [:], "")
		mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))
	}

	Void testPassThroughOn404() {
		mw	:= ErrOn4xxMiddleware()
		mw.enabled = false
		res := ButterResponse(404, "Argh!", [:], "")
		mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))
	}

	Void testThrowsServerErr() {
		mw	:= ErrOn4xxMiddleware()
		res := ButterResponse(404, "Argh!", [:], "")
		verifyErrTypeAndMsg(BadStatusErr#, ErrMsgs.badRequest(404, "Argh!", `/`)) {
			mw.sendRequest(MockTerminator([res]), ButterRequest(`/`))			
		}
	}
}