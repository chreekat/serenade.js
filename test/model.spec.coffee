require './spec_helper'

describe 'Serenade.Model', ->
  describe '#constructor', ->
    it 'sets the given properties', ->
      john = new Serenade.Model(name: 'John', age: 23)
      expect(john.age).to.eql(23)
      expect(john.name).to.eql('John')

    it 'returns the same object if given the same id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j123', age: 46)

      expect(john2.test).to.be.ok
      expect(john2.age).to.eql(46)
      expect(john2.name).to.eql('John')

    it 'returns different instances for same id on different constructors', ->
      Test1 = class Test extends Serenade.Model
      Test2 = class Test extends Serenade.Model

      john1 = new Test1(id: 'j123', name: 'John', age: 23)
      john2 = new Test2(id: 'j123', age: 46)

      expect(john1).not.to.eql(john2)
      expect(john1.age).to.eql(23)
      expect(john1.name).to.eql("John")
      expect(john2.age).to.eql(46)
      expect(john2.name).to.eql(undefined)

    it 'returns a new object when given a different id', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Serenade.Model(id: 'j456', age: 46)

      expect(john2.test).not.to.be.ok
      expect(john2.age).to.eql(46)
      expect(john2.name).to.not.exist

  describe '.extend', ->
    it 'sets up prototypes correctly', ->
      Test = Serenade.Model.extend()
      test = new Test(foo: 'bar')
      expect(test.foo).to.eql('bar')

    it 'copies over class variables', ->
      Test = Serenade.Model.extend()
      expect(typeof Test.hasMany).to.eql('function')

    it 'runs the provided constructor function', ->
      Test = Serenade.Model.extend(-> @foo = true)
      test = new Test()
      expect(test.foo).to.be.ok

    it 'works with the identity map', ->
      Person = Serenade.Model.extend()
      john1 = new Person(id: 'j123', name: 'John', age: 23)
      john1.test = true
      john2 = new Person(id: 'j123', age: 46)

      expect(john2.test).to.be.ok
      expect(john2.age).to.eql(46)
      expect(john2.name).to.eql('John')

  describe '.uniqueId', ->
    it 'is different for different classes', ->
      Test1 = class Test extends Serenade.Model
      Test2 = class Test extends Serenade.Model
      expect(Test1.uniqueId()).not.to.eql(Test2.uniqueId())

    it 'returns the same results when called multiple times', ->
      Test = class Test extends Serenade.Model
      expect(Test.uniqueId()).to.eql(Test.uniqueId())

    it 'is different for subclasses', ->
      Test1 = class Test extends Serenade.Model
      Test1.uniqueId()
      Test2 = class Test extends Test1
      expect(Test1.uniqueId()).not.to.eql(Test2.uniqueId())

  describe '.find', ->
    it 'creates a new blank object with the given id', ->
      document = Serenade.Model.find('j123')
      expect(document.id).to.eql('j123')

    it 'returns the same object if it has previously been initialized', ->
      john1 = new Serenade.Model(id: 'j123', name: 'John')
      john1.test = true
      john2 = Serenade.Model.find('j123')
      expect(john2.test).to.be.ok
      expect(john2.name).to.eql('John')

  describe '.property', ->
    it 'adds a property to the prototype', ->
      class Person extends Serenade.Model
        @property "name"
      john = new Person(name: "John")
      expect(-> john.name = "Johnny").to.triggerEvent john.change_name

    it 'makes property getters assignable', ->
      class Person extends Serenade.Model
        @property "name"
        @property "loudName"
        loudName: ->
          @name.toUpperCase()
      john = new Person(name: "John")
      expect(john.loudName).to.eql("JOHN")

    it 'adds multiple properties to the prototype', ->
      class Person extends Serenade.Model
        @property "firstName", "lastName"
      john = new Person(firstName: "John", lastName: "Smith")
      expect(-> john.firstName = "Johnny").to.triggerEvent john.change_firstName

    it 'adds multiple properties with options to the prototype', ->
      class Person extends Serenade.Model
        @property "firstName", "lastName", serialize: true
      john = new Person(firstName: "John", lastName: "Smith")
      expect(-> john.firstName = "Johnny").to.triggerEvent john.change_firstName
      expect(john.toJSON().lastName).to.eql("Smith")

  describe "#id", ->
    it "updates identify map when changed", ->
      class Person extends Serenade.Model
        @property "name"
      person = new Person(id: 5, name: "Nicklas")
      person.id = 10
      expect(person.id).to.eql(10)
      expect(Person.find(5).name).to.eql(undefined)
      expect(Person.find(10).name).to.eql("Nicklas")

