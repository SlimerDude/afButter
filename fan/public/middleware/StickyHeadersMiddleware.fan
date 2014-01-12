
** Middleware that automatically sets headers in each request, so you don't have to!
** 
** Only non-existing header values are set, leaving any existing values untouched. This means you can use sticky 
** headers to set default values and manually override them for individual requests.
class StickyHeadersMiddleware : ButterMiddleware {

	** The header values set in every request 
	HttpRequestHeaders stickyHeaders	:= HttpRequestHeaders()
	
	override ButterResponse sendRequest(Butter butter, ButterRequest req) {
		
		stickyHeaders.map.each |val, key| {
			if (!req.headers.containsKey(key))
				req.headers[key] = val
		}
		
		return butter.sendRequest(req)
	}
}

** A `ButterDish` for `StickyHeadersMiddleware`.
mixin StickyHeadersDish : ButterDish {

	** The header values set in every request 
	** 
	** @see `StickyHeadersMiddleware#stickyHeaders`
	HttpRequestHeaders stickyHeaders() {
		getStickHeadersMw.stickyHeaders
	}	

	private StickyHeadersMiddleware getStickHeadersMw() {
		findMiddleware(StickyHeadersMiddleware#)
	}	
}