require './_prepare'

sysPath = require 'path'

error = (what) ->

	if typeof what is 'string'

		return error -> throw Error what

	else if what instanceof Function

		try

			do what

			return null

		catch e

			return e

	else

		throw Error "bad argument for error"

ParsedError = mod 'ParsedError'

describe "constructor()"

it "should accept Error() instances", ->

	(->

		e = new ParsedError error ->

			throw Error "some message"

	).should.not.throw()

it "should accept ReferenceError() and other derivatives of Error()", ->

	(->

		e = new ParsedError error ->

			throw ReferenceError "some message"

	).should.not.throw()

it "should accept non errors", ->

	(->

		e = new ParsedError 'some string'

	).should.not.throw()

describe "message"

it "should return the original error message", ->

	e = new ParsedError error 'a'

	e.message.should.equal 'a'

describe "kind"

it "should return 'Error' for normal error", ->

	e = new ParsedError error 'a'

	e.kind.should.equal 'Error'

it "should recognize 'ReferenceError'", ->

	e = new ParsedError error -> a.b = c

	e.kind.should.equal 'ReferenceError'

describe "type"

it "should return original error type", ->

	e = new ParsedError error -> a.b = c

	expect(e.type).to.equal 'not_defined'

describe "arguments"

it "should return original error arguments", ->

	e = new ParsedError error -> a.b = c

	expect(e.arguments).to.be.like ['a']

describe "stack"

it "should return original error stack", ->

	e = new ParsedError error -> a.b = c

	expect(e.stack).to.equal e.error.stack

describe "trace"

it "should include correct information about each trace item", ->

	e = new ParsedError error -> a.b = c

	e.trace.should.have.length.above 2

	item = e.trace[0]

	item.should.include.keys 'original',

		'what', 'path', 'addr',
		'file', 'dir', 'col',
		'line', 'jsCol', 'jsLine'
		'packageName', 'shortenedPath', 'shortenedAddr'

	item.path.should.equal module.filename.replace(/[\\]+/g, '/')

	item.line.should.be.a 'number'
	item.col.should.be.a 'number'

describe "_rectifyPath()"

it "should work", ->

	ParsedError::_rectifyPath(
		'F:/a/node_modules/b/node_modules/d/node_modules/e/f.js'
	).path.should.equal '[a]/[b]/[d]/[e]/f.js'

it "should return path when `node_modules` is not present", ->

	ParsedError::_rectifyPath('a/b/c').path.should.equal 'a/b/c'
