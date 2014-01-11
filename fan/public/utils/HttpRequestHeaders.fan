
** A wrapper for HTTP request headers with accessors for some commonly used headings.
** Set a value to 'null' to remove it from the map.
** 
** @see `http://en.wikipedia.org/wiki/List_of_HTTP_header_fields`
class HttpRequestHeaders {
	
	private Str:Str headers

	new make(Str:Str headers) { this.headers = headers }

	** Content-Types that are acceptable for the response. 
	** 
	** Example: 'Accept: audio/*; q=0.2, audio/basic'
	QualityValues? accept {
		get { makeIfNotNull("Content-Length") { QualityValues(it, true) }}
		set { addOrRemove("Accept", it?.toStr) }
	}

	** List of acceptable encodings.
	** 
	** Example: 'Accept-Encoding: compress;q=0.5, gzip;q=1.0'
	QualityValues? acceptEncoding {
		get { makeIfNotNull("Accept-Encoding") { QualityValues(it, true) }}
		set { addOrRemove("Accept-Encoding", it?.toStr) }
	}

	** List of acceptable human languages for response.
	** 
	** Example: 'Accept-Language: da, en-gb;q=0.8, en;q=0.7'
	QualityValues? acceptLanguage {
		get { makeIfNotNull("Accept-Language") { QualityValues(it, true) }}
		set { addOrRemove("Accept-Language", it?.toStr) }
	}

	** The length of the request body in octets (8-bit bytes).
	** 
	** Example: 'Content-Length: 348'
	Int? contentLength {
		get { makeIfNotNull("Content-Length") { Int.fromStr(it) }}
		set { addOrRemove("Content-Length", it?.toStr) }
	}

	** The MIME type of the body of the request (used with POST and PUT requests)
	** 
	** Example: 'Content-Type: application/x-www-form-urlencoded'
	MimeType? contentType {
		get { makeIfNotNull("Content-Type") { MimeType(it, true) }}
		set { addOrRemove("Content-Type", it?.toStr) }
	}

	** The domain name of the server (for virtual hosting), and the TCP port number on which the 
	** server is listening. The port number may be omitted if the port is the standard port for 
	** the service requested.
	** 
	** Example: 'Host: www.alienfactory.co.uk:8069'
	Uri? host {
		get { headers["Host"]?.toUri }
		set { addOrRemove("Host", it?.encode) }
	}

	** Allows a 304 Not Modified to be returned if content is unchanged.
	** 
	** Example: 'If-Modified-Since: Sat, 29 Oct 1994 19:43:31 GMT'
	DateTime? ifModifiedSince {
		get { makeIfNotNull("If-Modified-Since") { DateTime.fromHttpStr(it, true) }}
		set { addOrRemove("If-Modified-Since", it?.toHttpStr) }
	}

	** Allows a 304 Not Modified to be returned if content is unchanged.
	** 
	** Example: 'If-None-Match: "737060cd8c284d8af7ad3082f209582d"'
	Str? ifNoneMatch {
		get { headers["If-None-Match"] }
		set { addOrRemove("If-None-Match", it) }
	}

	** Initiates a request for cross-origin resource sharing.
	** 
	** Example: 'Origin: http://www.example-social-network.com'
	Str? origin {
		get { headers["Origin"] }
		set { addOrRemove("Origin", it) }
	}

	** This is the address of the previous web page from which a link to the currently requested 
	** page was followed. 
	** 
	** Example: 'Referer: http://en.wikipedia.org/wiki/Main_Page'
	Uri? referrer {
		// yeah, I know I've mispelt referrer!
		// see `https://en.wikipedia.org/wiki/HTTP_referrer`
		get { headers["Referer"]?.toUri }
		set { addOrRemove("Referer", it?.encode) }
	}

	** The user agent string of the user agent.
	** 
	** Example: 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:12.0) Gecko/20100101 Firefox/21.0'
	Str? userAgent {
		get { headers["User-Agent"] }
		set { addOrRemove("User-Agent", it) }
	}

	** Mainly used to identify Ajax requests. 
	** 
	** Example: 'X-Requested-With: XMLHttpRequest'
	Str? xRequestedWith {
		get { headers["X-Requested-With"] }
		set { addOrRemove("X-Requested-With", it) }
	}

	** Identifies the originating IP address of a client connecting through an HTTP proxy. 
	** 
	** Example: 'X-Forwarded-For: client, proxy1, proxy2'
	Str[]? xForwardedFor {
		get { headers["X-Forwarded-For"]?.split(',') }
		set { addOrRemove("X-Forwarded-For", it?.join(", ")) }
	}



	@Operator
	Str? get(Str name) {
		headers[name]
	}

	Void each(|Str val, Str key| c) {
		headers.each(c)
	}
	
	Str:Str map() {
		headers
	}
	
	private Obj? makeIfNotNull(Str name, |Obj->Obj| func) {
		val := headers[name]
		return (val == null) ? null : func(val)
	}

	private Void addOrRemove(Str name, Str? value) {
		if (value == null)
			headers.remove(name)
		else
			headers[name] = value
	}
}
