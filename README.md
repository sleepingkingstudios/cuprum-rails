# Cuprum::Rails

An integration between Rails and the Cuprum library.

Cuprum::Rails defines the following objects:

- [Collections](#collections): A collection for performing operations on ActiveRecord models using the standard `Cuprum::Collections` interface.
    - [Commands](#commands): @todo
- [Controllers](#controllers): @todo
    - [Actions](#actions): @todo
    - [Requests](#requests): @todo
    - [Resources](#resources): @todo
    - [Responders](#responders) and [Responses](#responses): @todo
    - [Serializers](#serializers): @todo

## About

Cuprum::Rails provides a toolkit for using the Cuprum command pattern and the flexibility of Cuprum::Collections to build Rails applications. Using the `Cuprum::Rails::Collection`, you can perform operations on ActiveRecord models, leveraging a standard interface to control where your data is stored and how it is queried. For example, you can inject a mock collection into unit tests for precise control over queried values and blinding fast tests without having to hit the database directly.

Using `Cuprum::Rails::Controller` takes this one step further, breaking apart the traditional controller into a sequence of steps with individual responsibilities. This has two main benefits. First, being explicit about how your controllers perform and respond to actions allows for precise control at each step of the process. Second, each step is encapsulated, which allows for easier testing and reuse. This not only makes testing simpler - you can test your business logic by examining an Action result, rather than parsing a rendered HTML page - but allows you to reuse individual components. The goal is to reduce the boilerplate inherent in writing a Rails application by allowing you to define only the code that is unique to the controller, action, or process.

### Why Cuprum::Rails?

Rails is a highly opinionated framework: one of the pillars of The Rails Doctrine is the principle that "The menu is omakase". This is one of the keys to the framework's success, providing a welcoming environment for new developers as well as powerful tools for developing applications - as long as those applications are built The Rails Way.

This is great for rapidly developing prototypes, proof of concept or proof of market applications, or even smaller applications for content management, e-commerce, and so on. There are good reasons why Rails has made so much headway against established behemoths such as WordPress. That being said, many companies are using Rails to build applications that are much more ambitious, and at that scale the standard Rails patterns start to fall apart. Omakase is no longer just right.

Cuprum::Rails is intended to address two of the pain points of Big Rails. The first is architectural: any Rails developer of a certain age will remember the wars over Fat Controllers versus Fat Models. The rise of Service Objects provides a way forward, but in practice this can be something of a Wild West - everything gets dumped in an `app/services` directory, each file looks and works differently. The [Cuprum](github.com/sleepingkingstudios/cuprum) gem is designed to provide a solution to this chaos. Defining a command gives you the benefits of encapsulation, control flow, and *consistency* - every command defines one `#call` method and returns a result.

The second benefit is *reusability*. Breaking down a controller into its constituent steps means you don't have to reimplement each of those steps each time you create a controller or add an action. You can define what it means to respond to an HTML or JSON request once, and modify it on a per-action basis when you need custom behavior. You can subclass the resourceful action commands to leverage basic controller functionality, such as performing filtered queries. And, of course, you gain all the benefits of decoupling commands from your controller - you can use the same functionality in a controller action, as an asynchronous job, or as a command-line function.

### Compatibility

Cuprum::Collections is tested against Ruby (MRI) 2.6 through 3.0.

### Documentation

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2021 Rob Smith

Stannum is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum-rails.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/cuprum-rails/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/cuprum-rails/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Code of Conduct

Please note that the `Cuprum::Collections` project is released with a [Contributor Code of Conduct](https://github.com/sleepingkingstudios/cuprum-rails/blob/master/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

<!-- ## Getting Started  -->

## Reference

<a id="collections"></a>

### Collections

```ruby
require 'cuprum/rails/collection'
```

A `Cuprum::Rails::Collection` implements the [Cuprum::Collections](https://github.com/sleepingkingstudios/cuprum-collections) interface for `ActiveRecord` models. It defines a set of [commands](#commands) that implement persistence and query operations, and a `#query` method to directly perform queries on the data.

```ruby
collection = Cuprum::Rails::Collection.new(record_class: Book)

# Add an item to the collection.
steps do
  # Build the book from attributes.
  book = step do
    collection.build_one.call(
      attributes: { id: 10, title: 'Gideon the Ninth', author: 'Tamsyn Muir' }
    )
  end

  # Validate the book using its default validations.
  step { collection.validate_one.call(entity: book) }

  # Insert the validated book to the collection.
  step { collection.insert_one.call(entity: book) }
end

# Find an item by primary key.
book = step { collection.find_one.call(primary_key: 10) }

# Find items matching a filter.
books = step do
  collection.find_matching.call(
    limit: 10,
    order: [:author, { title: :descending }],
    where: lambda do
      published_at: greater_than('1950-01-01')
    end
  )
end
```

Initializing a collection requires the `:record_class` keyword, which should be a Class that inherits from `ActiveRecord::Base`. You can also specify some optional keywords:

- The `:collection_name` parameter sets the name of the collection. It is used to create an envelope for query commands, such as the `FindMany`, `FindMatching` and `FindOne` commands.
- The `:default_contract` parameter sets a default contract for validating collection entities. If no `:contract` keyword is passed to the `ValidateOne` command, it will use the default contract to validate the entity instead of the validation constraints defined for the model.
- The `:member_name` parameter is used to create an envelope for singular query commands such as the `FindOne` command. If not given, the member name will be generated automatically as a singular form of the collection name.
- The `:primary_key_name` parameter specifies the attribute that serves as the primary key for the collection entities. The default value is `:id`.
- The `:primary_key_type` parameter specifies the type of the primary key attribute. The default value is `Integer`.

<a id="commands"></a>

#### Commands

Structurally, a collection is a set of commands, which are instances of `Cuprum::Command` that implement a persistence or querying operation and wrap that operation with parameter validation and error handling. For more information on Cuprum commands, see the [Cuprum gem](github.com/sleepingkingstudios/cuprum).

##### Assign One

The `AssignOne` command takes an attributes hash and a record, assigns the given attributes to the record, and returns the record.

```ruby
book       = Book.new('id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir')
attributes = { 'title' => 'Harrow the Ninth', 'published_at' => '2020-08-04' }
result     = collection.assign_one.call(attributes: attributes, entity: entity)

result.value.class
#=> Book
result.value.attributes
#=> {
#     'id'           => 10,
#     'title'        => 'Harrow the Ninth',
#     'author'       => 'Tamsyn Muir',
#     'series'       => nil,
#     'category'     => nil,
#     'published_at' => '2020-08-04'
#   }
```

If the attributes hash includes one or more attributes that are not defined for that record class, the `#assign_one` command can return a failing result with an `ExtraAttributes` error.

##### Build One

The `BuildOne` command takes an attributes hash and returns a new record whose attributes are equal to the given attributes. This does not validate or persist the record; it is equivalent to calling `record_class.new` with the attributes.

```ruby
attributes = { 'id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir' }
result     = collection.build_one.call(attributes: attributes, entity: entity)

result.value.class
#=> Book
result.value.attributes
#=> {
#     'id'           => 10,
#     'title'        => 'Gideon the Ninth',
#     'author'       => 'Tamsyn Muir',
#     'series'       => nil,
#     'category'     => nil,
#     'published_at' => nil
#   }
```

If the attributes hash includes one or more attributes that are not defined for that record class, the `#build_one` command can return a failing result with an `ExtraAttributes` error.

##### Destroy One

The `DestroyOne` command takes a primary key value and removes the record with the specified primary key from the collection.

```ruby
result = collection.destroy_one.call(primary_key: 0)

collection.query.where(id: 0).exists?
#=> false
```

If the collection does not include a record with the specified primary key, the `#destroy_one` command will return a failing result with a `NotFound` error.

##### Find Many

The `FindMany` command takes an array of primary key values and returns the records with the specified primary keys. The entities are returned in the order of the specified primary keys.

```ruby
result = collection.find_many.call(primary_keys: [0, 1, 2])
result.value
#=> [
#     #<Book
#       id:           0,
#       title:        'The Hobbit',
#       author:       'J.R.R. Tolkien',
#       series:       nil,
#       category:     'Science Fiction and Fantasy',
#       published_at: '1937-09-21'
#     >,
#     #<Book
#       id:           1,
#       title:        'The Silmarillion',
#       author:       'J.R.R. Tolkien',
#       series:       nil,
#       category:     'Science Fiction and Fantasy',
#       published_at: '1977-09-15'
#     >,
#     #<Book
#       id:           2,
#       title:        'The Fellowship of the Ring',
#       author:       'J.R.R. Tolkien',
#       series:       'The Lord of the Rings',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1954-07-29'
#     >
#   ]
```

The `FindMany` command has several options:

- The `:allow_partial` keyword allows the command to return a passing result if at least one of the entities is found. By default, the command will return a failing result unless an entity is found for each primary key value.
- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the name of the collection and whose value is the returned entities array.

    ```ruby
    result = collection.find_many.call(primary_keys: [0, 1, 2], envelope: true)
    result.value
    #=>  { books: [#<Book>, #<Book>, #<Book>] }
    ```

- The `:scope` keyword allows you to pass a query to the command. Only entities that match the given scope will be found and returned by `#find_many`.

If the collection does not include an entity with each of the specified primary keys, the `#find_many` command will return a failing result with a `NotFound` error.

##### Find Matching

The `FindMatching` command takes a set of query parameters and queries data from the collection. You can specify filters using the `:where` keyword or by passing a block, sort the results using the `:order` keyword, or return a subset of the results using the `:limit` and `:offset` keywords. For full details on performing queries, see [Queries](#queries), below.

```ruby
result =
  collection
  .find_matching
  .call(order: :published_at, where: { series: 'Earthsea' })
result.value
#=> [
#     #<Book
#       id:           7,
#       title:        'A Wizard of Earthsea',
#       author:       'Ursula K. LeGuin',
#       series:       'Earthsea',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1968-11-01'
#     >,
#     #<Book
#       id:           8,
#       title:        'The Tombs of Atuan',
#       author:       'Ursula K. LeGuin',
#       series:       'Earthsea',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1970-12-01'
#     >,
#     #<Book
#       id:           9,
#       title:        'The Farthest Shore',
#       author:       'Ursula K. LeGuin',
#       series:       'Earthsea',
#       category:     'Science Fiction and Fantasy',
#       published_at: '1972-09-01'
#     >
#   ]
```

The `FindMatching` command has several options:

- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the name of the collection and whose value is the returned entities array.

    ```ruby
    result = collection.find_matching.call(where: { series: 'Earthsea' }, envelope: true)
    result.value
    #=>  { books: [#<Book>, #<Book>, #<Book>] }
    ```

- The `:limit` keyword caps the number of results returned.
- The `:offset` keyword skips the specified number of results.
- The `:order` keyword specifies the order of results.
- The `:scope` keyword allows you to pass a query to the command. Only entities that match the given scope will be found and returned by `#find_matching`.
- The `:where` keyword defines filters for which results are to be returned.

##### Find One

The `FindOne` command takes a primary key value and returns the record with the specified primary key.

```ruby
result = collection.find_one.call(primary_key: 1)
result.value
#=> #<Book
#     id:           1,
#     title:        'The Silmarillion',
#     author:       'J.R.R. Tolkien',
#     series:       nil,
#     category:     'Science Fiction and Fantasy',
#     published_at: '1977-09-15'
#   >
```

The `FindOne` command has several options:

- The `:envelope` keyword wraps the result value in an envelope hash, with a key equal to the singular name of the collection and whose value is the returned record.

    ```ruby
    result = collection.find_one.call(primary_key: 1, envelope: true)
    result.value
    #=>  { book: #<Book> }
    ```

- The `:scope` keyword allows you to pass a query to the command. Only an entity that match the given scope will be found and returned by `#find_one`.

If the collection does not include a record with the specified primary key, the `#find_one` command will return a failing result with a `NotFound` error.

##### Insert One

The `InsertOne` command takes a record and inserts that record into the collection.

```ruby
book       = Book.new('id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir')
result     = collection.insert_one.call(entity: book)

result.value
#=> #<Book
#     id:           10,
#     title:        'Gideon the Ninth',
#     author:       'Tamsyn Muir',
#     series:       nil,
#     category:     nil,
#     published_at: nil
#   >

collection.query.where(id: 10).exists?
#=> true
```

If the collection already includes a record with the specified primary key, the `#insert_one` command will return a failing result with an `AlreadyExists` error.

##### Update One

The `UpdateOne` command takes a record and updates the corresponding record in the collection.

```ruby
book   = collection.find_one.call(1).value
book   = book.assign_attributes('author' => 'John Ronald Reuel Tolkien')
result = collection.update_one(entity: book)

result.value
#=> #<Book
#     id:           1,
#     title:        'The Silmarillion',
#     author:       'J.R.R. Tolkien',
#     series:       nil,
#     category:     'Science Fiction and Fantasy',
#     published_at: '1977-09-15'
#   >

collection
  .query
  .where(title: 'The Silmarillion', author: 'John Ronald Reuel Tolkien')
  .exists?
#=> true
```

If the collection does not include a record with the specified records's primary key, the `#update_one` command will return a failing result with a `NotFound` error.

##### Validate One

The `ValidateOne` command takes an entity and an optional `Stannum` contract. If the `:contract` keyword is given, the record is matched against the contract; otherwise, the record is matched using the native validations defined for the record class.

```ruby
book   = Book.new('id' => 10, 'title' => 'Gideon the Ninth', 'author' => 'Tamsyn Muir')
result = collection.validate_one.call(entity: book)
result.success?
#=> true
```

If the contract does not match the entity, the `#validate_one` command will return a failing result with a `ValidationFailed` error.

<a id="repositories"></a>

#### Repositories

```ruby
require 'cuprum/rails/repository'
```

A `Cuprum::Rails::Repository` is a group of Rails collections. A single repository might represent all or a subset of the tables in your database.

```ruby
repository = Cuprum::Collections::Repository.new
repository.key?('books')
#=> false

repository.add(books_collection)

repository.key?('books')
#=> true
repository.keys
#=> ['books']
repository['books']
#=> the books collection
```

<a id="controllers"></a>

### Controllers

<a id="actions"></a>

#### Actions

<a id="resources"></a>

#### Requests

<a id="requests"></a>

#### Resources

<a id="responders"></a>

#### Responders

<a id="responses"></a>

##### Responses

<a id="serializers"></a>

#### Serializers
