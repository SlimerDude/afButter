using web::WebRes
using web::WebUtil
using util::JsonInStream

** The HTTP response.
class ButterResponse {

	** The HTTP status code.
	Int statusCode

	** The HTTP status message.
	Str statusMsg

	** The HTTP repsonse headers.
	HttpResponseHeaders headers { private set }

	** HTTP version of the response.
	Version version	:= Butter.http11

	** The request body.
	Body	body { private set }

	** A temporary store for request data, use to pass data between middleware.
	Str:Obj data	:= [:]

	** Creates a response reading real HTTP values from an 'InStream'.
	** Note the whole response body is read in.
	new makeFromInStream(InStream in) {
//		// for testing
//		// note this WILL hang when reading a chunked response
//		out := `test/response2.txt`.toFile.out(false, 0)
//		while (true)
//			out.write(in.read).flush

		res := null as Str
		try {
			resVer	:= (Version?) null
			res 	= in.readLine
			if		(res == null) throw IOErr("Received no response")
			if 		(res.startsWith("HTTP/1.0")) resVer = Butter.http10
			else if (res.startsWith("HTTP/1.1")) resVer = Butter.http11
			else throw IOErr("Unknown HTTP version: ${res}")

			statusCode 	= res[9..11].toInt
			statusMsg 	= res.size > 13 ? res[13..-1] : ""
			headers		= HttpResponseHeaders(WebUtil.parseHeaders(in))

			// See "Custom Charset Implementations" - https://fantom.org/forum/topic/2740
			// Should we perhaps check and replace the Charset with a fake valid one?
			// sys::ParseErr: Invalid Charset: 'ISO-8859': java.nio.charset.UnsupportedCharsetException: ISO-8859
			// sys::ParseErr: Invalid Charset: 'UTF-7': java.nio.charset.UnsupportedCharsetException: UTF-7
			//   fan.sys.Charset.fromStr (Charset.java:47)
			//   fan.sys.Charset.fromStr (Charset.java:26)
			//   fan.sys.MimeType.charset (MimeType.java:288)
			//   web::WebUtil.headersToCharset (WebUtil.fan:240)
			//   web::WebUtil.doMakeContentInStream (WebUtil.fan:281)
			//   web::WebUtil.makeContentInStream (WebUtil.fan:260)

			// ChunkInStream throws NullErr if the response has no body, e.g. HEAD requests
			// see http://fantom.org/sidewalk/topic/2365
			// I could check the Content-Length header, but why should I trust it!?
			instream := WebUtil.makeContentInStream(headers.val, in)

			body = Body(headers, instream)
		}
		catch (IOErr e) throw e
		catch (Err err) throw IOErr("Invalid HTTP response: $res", err)
	}

	** Create a response. 'body' may either be a 'Str' or a 'Buf'.
	**
	** This is a convenience ctor suitable for most applications.
	new make(Int statusCode, [Str:Str]? headers := null, Obj? body := null) {
		if (body != null && body isnot Str && body isnot Buf)
			throw ArgErr("Invalid Body, must be either null, Str, or Buf")
		this.statusCode = statusCode
		this.statusMsg 	= WebRes.statusMsg[statusCode] ?: "Unknown"
		this.headers	= HttpResponseHeaders(headers)

		// can't use "switch" 'cos Buf is actually a MemBuf!
		if (body is Str)
			this.body	= Body(this.headers, (Str) body)
		else
		if (body is Buf)
			this.body	= Body(this.headers, (Buf) body)
		else
			this.body	= Body(this.headers, null as Str)
	}

	// Used by Bounce - so keep around!
	** Create a response. 'body' may either be a 'Str' or a 'Buf'.
	new makeWithHeaders(Int statusCode, HttpResponseHeaders headers, Obj? body := null) {
		if (body != null && body isnot Str && body isnot Buf)
			throw ArgErr("Invalid Body, must be either null, Str, or Buf")
		this.statusCode = statusCode
		this.statusMsg 	= WebRes.statusMsg[statusCode] ?: "Unknown"
		this.headers	= headers
		// can't use "switch" 'cos Buf is actually a MemBuf!
		if (body is Str)
			this.body	= Body(this.headers, (Str) body)
		else
		if (body is Buf)
			this.body	= Body(this.headers, (Buf) body)
		else
			this.body	= Body(this.headers, null as Str)
	}

	** Dumps a debug string that in some way resembles the full HTTP response.
	Str dump(Bool dumpBody := true) {
		buf := StrBuf()
		out := buf.out

		out.print("HTTP/${version} ${statusCode} ${statusMsg}\n")
		headers.each |v, k| { out.print("${k}: ${v}\n") }
		out.print("\n")

		if (dumpBody)
			if (body.buf != null && body.buf.size > 0) {
				try	  out.print(GzipMiddleware.deGzipResponse(this).readAllStr)
				catch out.print("** ERROR: Body does not contain string content **")
			}

		return buf.toStr
	}

	@NoDoc @Deprecated { msg="Use 'body.str' instead" }
	Str? asStr() {
		body.str
	}

	@NoDoc @Deprecated { msg="Use 'body.buf' instead" }
	Buf? asBuf() {
		body.buf
	}

	@NoDoc @Deprecated { msg="Use 'body.buf.seek(0).in' instead" }
	InStream? asInStream() {
		body.buf?.seek(0)?.in
	}

	@NoDoc @Deprecated { msg="Use 'body.jsonObj' instead" }
	Obj? asJson() {
		body.jsonObj
	}

	@NoDoc @Deprecated { msg="Use 'body.jsonMap' instead" }
	[Str:Obj?]? asJsonMap() {
		body.jsonMap
	}

	@NoDoc
	override Str toStr() {
		"$statusCode - $statusMsg"
	}
}
