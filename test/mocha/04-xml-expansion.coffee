Fixture = require './lib/fixture'
{eventually, prepare} = require './lib/utils'
{unitTests} = require './lib/segregation'
{nockTest} = require './lib/mock'
nock = require 'nock'
fs = require 'fs'

# To expand the '*' is handled by `imjs` library, therefore unit test (expandStar)

unitTests() && describe 'Query', ->

  before ->
    nock.recorder.rec
      logging: (content) -> fs.appendFile 'record.txt', content, (err) ->
        console.log 'fk'
  
  after ->
    nock.restore()

  describe 'expandStar', ->

    {service} = new Fixture()

    describe "#select(['*'])", ->
      @beforeEach prepare ->
        # nockTest()
        service.query root: 'Employee'

      it 'should expand stars to the summary fields', eventually (q) ->
        expected_views = [
          'Employee.name',
          'Employee.department.name',
          'Employee.department.manager.name',
          'Employee.department.company.name',
          'Employee.fullTime',
          'Employee.address.address'
        ]
        q.select ['*']
        q.views.should.eql expected_views

      it 'should expand double stars to all fields', eventually (q) ->
        expected_views = [
          'Employee.name',
          'Employee.department.name',
          'Employee.department.manager.name',
          'Employee.department.company.name',
          'Employee.fullTime',
          'Employee.address.address',
          'Employee.age',
          'Employee.end',
          'Employee.id'
        ]
        q.select ['**']
        q.views.sort().should.eql expected_views.sort()

      it 'should be able to expand paths ending in a star', eventually (q) ->
        expected_views = [ 'Employee.department.name' ]
        q.select ['department.*']
        q.views.should.eql expected_views


