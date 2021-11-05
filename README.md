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

<a id="commands"></a>

#### Commands

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
