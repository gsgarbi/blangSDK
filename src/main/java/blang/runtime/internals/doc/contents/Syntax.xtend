package blang.runtime.internals.doc.contents

import blang.runtime.internals.doc.components.Document
import blang.runtime.internals.doc.Categories
import blang.runtime.internals.doc.components.Code.Language

class Syntax {
  
  public val static Document page = new Document("Syntax reference") [
    category = Categories::reference
    
    section("Overview of the syntax reference") [
      it += '''
        In the following, we assume, the reader has already looked at the «LINK(GettingStarted::page)»Getting started page.«ENDLINK»
        
        This document attempts to be as self-contained as possible. Blang is designed to 
        be usable with very minimal past programming exposure.  
        However, to fully master the advanced features of Blang, familiarity with a modern 
        multi-paradigm statically typed language is recommended. 
        
        Additionally, for readers familiar with Java and using the Blang IDE, you can right click on any Blang file and select 
        «SYMB»Open generated file«ENDSYMB» to see the Java code generated by Blang. 
    '''
    ]
    
    section("Types") [
      it += '''
        The information stored by programs into a computer's memory is highly structured into chunks.  
        Each chunk is called an «EMPH»object«ENDEMPH». Some of the objects have shared properties. A property that 
        allows us to group objects is called a «EMPH»type«ENDEMPH». 
        
        Concretely, types in Blang are equivalent to «EMPH»Java types«ENDEMPH» (a terminology that encompasses 
        Java classes, interfaces, primitives, enumerations and annotation interfaces). This means any 
        Java type can be imported and used in Blang, and any model defined in Blang can be imported and used 
        in Java with no extra work needed.
      '''
    ]
    
    section("Comments") [
      it += '''
        Single line comments use the syntax «SYMB»// some comment spanning the rest of the line«ENDSYMB».
        
        Multi-line comments use «SYMB»/* many lines can go here */«ENDSYMB».
        
        In the following, we use comments to give contextual explanation on syntax examples.
      '''
    ]
    
    section("Models") [
      it += '''The syntax for Blang models is as follows:'''
      code(Language.blang, '''
        package my.namespace // optional
        
        // import statements
        
        model NameOfModel {
          
          // variables declarations
          
          laws {
            // laws declaration 
          }
          
          generate(nameOfRandomObject) { // optional
            // generate block 
          }
        }
      ''')
      it += '''In the next few sections we describe each element in the above example in detail.'''
      
      section("Packages and imports") [
        it += '''
          Packages in Blang work as in Java. Their syntax is similar too except that the semicolumn can be skipped in 
          Blang.
          
          Similarly, «SYMB»import«ENDSYMB» statements also support the Java counterparts, for example: 
        '''  
        code(Language.blang, '''
          import org.apache.spark.sql.Dataset
          import static org.apache.spark.sql.functions.col
        ''')
        it += '''
          «SYMB»import static«ENDSYMB» is used to import a function (the function called «SYMB»col«ENDSYMB» in
          the above example), while standard imports are for types. The name "static" comes from Java where "static method" means 
          a "regular" function, i.e. a procedure that exists outside of the context of an object. 
          
          Blang additionally support «EMPH»extension«ENDEMPH» import directives of the form'''
       code(Language.blang, '''import static extension my.namespace.myfunction''')
       it += '''
          Extensions methods are described in the XExpression section below.
          
          Blang automatically imports:  
       '''
       unorderedList[ // TODO extract those
         it += '''
          all the types in the following packages: 
            «SYMB»blang.core«ENDSYMB», 
            «SYMB»blang.distributions«ENDSYMB»,
            «SYMB»blang.io«ENDSYMB», 
            «SYMB»blang.types«ENDSYMB», 
            «SYMB»blang.mcmc«ENDSYMB», 
            «SYMB»java.util«ENDSYMB», 
            «SYMB»xlinear«ENDSYMB»;
         '''
         it += '''
          all the static function in the following files: 
            «SYMB»xlinear.MatrixOperations«ENDSYMB», 
            «SYMB»bayonet.math.SpecialFunctions«ENDSYMB», 
            «SYMB»org.apache.commons.math3.util.CombinatoricsUtils«ENDSYMB», 
            «SYMB»blang.types.StaticUtils«ENDSYMB»; 
         '''
         it += '''
          as static extensions all the static function in the following files:
            «SYMB»xlinear.MatrixExtensions«ENDSYMB», 
            «SYMB»blang.types.ExtensionUtils«ENDSYMB».  
         '''
       ]
      ]
      
      section("Model variables") [
        it += '''
          Variables are declared using the following syntax:
        '''
        code(Language.blang, '''
          random Type1 name1
          random Type2 name2 ?: { ... } // optional initialization block
          random Type3 name3 ?: someStaticallyImportedFunction(name2) // another optional init
          param Type4 name4
          param Type5 name5 ?: { .. } // one more optional init block 
        ''')
        it += '''
          Each variable is declared as either «SYMB»random«ENDSYMB »or «SYMB»param«ENDSYMB» (parameter). 
          This controls how the model can be invoked by other models. 
          Parameters can become random when the model is used in the context of a larger model.
          
          In the above example, «SYMB»Type1«ENDSYMB», «SYMB»Type2«ENDSYMB», ... can syntactically 
          be of any type. However at runtime some requirement 
          «LINK(GettingStarted::page)»must be met by these types«ENDLINK». 
          
          Initialization blocks are XExpressions, which admit a rich and concise, Turing-complete syntax, 
          described in more details below. For multi-line expressions, surround the code with curly braces, 
          «SYMB»{«ENDSYMB», «SYMB»}«ENDSYMB». For one-line expressions, braces can be skipped.
          
          Initialization blocks are used in the main model to provide alternatives to command line 
          arguments. In other words, Blang calls them when no command line arguments are provided for 
          the variable associated with the init block. If an argument is provided for the variable, 
          the init block will be ignored. 
          
          Initialization blocks can use the values of the other variables listed previously. 
          
          Initialization blocks are not currently used in the context of the model being used by 
          a parent model.'''
      ]
      
      section("Laws") [
        it += '''
          Laws (prior or conditional distributions) can be either defined by invoking another Blang model 
          («EMPH»composite laws«ENDEMPH») or by defining one or several «EMPH»factors«ENDEMPH».
          
          During initialization, composite laws are recursively unrolled until a list of all factors is 
          created. The final model is the product of all these factors (more precisely, the sum of all the 
          log-factors). 
        '''
        section("Composite laws") [
          it += '''Composite laws are declared as follows:'''
          code(Language.blang, '''
            variableExpression1, variableExpression2, ... 
              | conditioning1, conditioning2, ... 
              ~ DistributionName(expression1, expression2, ...)
          ''')
          it += '''
            DistributionName refers to another Blang model, properly imported unless it is in an automatically imported package. 
            Variables «SYMB»variableExpression1«ENDSYMB», «SYMB»variableExpression2«ENDSYMB», ... are matched from left to right in the same order as 
            the «SYMB»random«ENDSYMB» variables are declared in the imported Blang model. Each can be an arbitrary XExpression, which is executed once at initialization time. 
            One important example is an XExpression that just returns a variable or parameter declared previously via the keyword «SYMB»random«ENDSYMB» 
            or «SYMB»param«ENDSYMB». Another important example is obtaining a variable from a collection of variable, e.g. 
            «SYMB»someList.get(anIndex)«ENDSYMB».
            
            Each conditioning expression in «SYMB»conditioning1«ENDSYMB», «SYMB»conditioning2«ENDSYMB», ... can take one of two 
            possible forms. First, it can be simply one of the names declared via the keyword «SYMB»random«ENDSYMB» or «SYMB»param«ENDSYMB». 
            Second, it can be a declaration of the form «SYMB»TypeName conditioningName = XExpression«ENDSYMB», where the «SYMB»XExpression«ENDSYMB» 
            is executed once at initialization time. An example of the latter from an HMM: «SYMB»IntVar prevState = states.get(time - 1)«ENDSYMB».
            
            Each argument in «SYMB»expression1«ENDSYMB», «SYMB»expression2«ENDSYMB», ... is an XExpression matched from left to right in the same 
            order as the «SYMB»param«ENDSYMB» variables are declared in the imported Blang model. In contrast to the other XExpressions discussed above,
            the XExpression in the arguments are recomputed each time the factors are evaluated during inference. This correspond to the natural 
            behaviour one would expect from the mathematical notation. For example, if we write «SYMB»x | y ~ Normal(f(y), 1.0)«ENDSYMB», we expect the 
            expression for the mean, «SYMB»f(y)«ENDSYMB» to be recomputed at each evaluation.
          '''
        ]
        section("Atomic laws (numerical factors)") [
          it += '''Atomic laws are declared as follows:'''
          code(Language.blang, '''
            logf(expression1, expression2, ...) { .. }
          ''')
          it += '''
            The block «SYMB»{ ... }«ENDSYMB» contains an XExpression returning the probability for this factor as a double in log scale. 
            
            Each argument in «SYMB»expression1«ENDSYMB», «SYMB»expression2«ENDSYMB», ... can take one of two 
            possible forms. First, it can be simply one of the names declared via the keyword «SYMB»random«ENDSYMB» or «SYMB»param«ENDSYMB». 
            Second, it can be a declaration of the form «SYMB»TypeName conditioningName = XExpression«ENDSYMB», where the «SYMB»XExpression«ENDSYMB» 
            is executed once at initialization time. 
          '''
        ]
        section("Atomic laws (indicator factors)") [
          it += '''Indicator factors are used to mark the support of a distribution:'''
          code(Language.blang, '''
            indicator(expression1, expression2, ...) { .. }
          ''')
          it += '''
            The block «SYMB»{ ... }«ENDSYMB» contains an XExpression returning a boolean value, whether the current configuration is in the support or not. 
            
            Each argument in «SYMB»expression1«ENDSYMB», «SYMB»expression2«ENDSYMB», ... are defined as in numerical factors.
          '''
        ]
        section("Atomic laws (constraint markers)") [
          it += '''
            In certain cases, it is useful to mark a variable as having special constraints, to disable the standard 
            sampling machinery and use specialized samplers instead. For example, this should be used when a simplex is used in a model to 
            avoid attempting naive sampling of the individual entries.
          '''
          code(Language.blang, '''
            variable is Constrained
          ''')
        ]
        section("Loops in laws block") [
          it += '''
            The syntax for loop appearing at the top level of laws block should follow
          '''
          code(Language.blang, '''
            for (IteratorType iteratorName : range) {
              ...
            }
          ''')
          it += '''
            The «SYMB»range«ENDSYMB» is an XExpression returning an instance of «SYMB»Iterable«ENDSYMB». Also the range 
            should not be random (i.e. should not change during sampling). However, sampling of infinite 
            dimensional objects can be handled by creating dedicated types. Indeed, loops «EMPH»inside«ENDEMPH» XExpressions 
            (described later in this document) are much more general. 
            
            Any loops in Blang can be nested. 
          ''' // TODO: link to range syntax
        ]
      ]
      
      section("Generate block") [
        it += '''
          The optional generate block, an XExpression, provides an alternative but equivalent description of the same model. It is syntactically optional, 
          but is required in certain but not all runtime contexts. 
          
          If all the laws in the model are composite, and the components already provide generate blocks, it is not necessary to provide a 
          generate block.
          
          Conversely, if all the laws are atomic, providing a generate block is necessary for several runtime tasks, including:
        '''
        orderedList[
          it += '''
            Sequential change of measure methods, which use exact samples from the prior as the initial probability measure in a sequence of 
            measures ending in the target posterior distribution.
          '''
          it += '''
            Correctness tests, which rely on testing the equivalence between the «SYMB»laws«ENDSYMB» and «SYMB»generate«ENDSYMB»
            implementations. 
          '''
        ]
        it += '''
          The argument name «SYMB»nameOfRandomObject«ENDSYMB» in «SYMB»generate(nameOfRandomObject)«ENDSYMB» provides an arbitrary name to the 
          input random number generator. No type is provided as the argument is always a subtype of «SYMB»java.util.Random«ENDSYMB». In practice, 
          the runtime uses the subtype «SYMB»bayonet.distributions.Random«ENDSYMB» which provides a better algorithm (a Mersenne twister) as well 
          as cross compatibility between «SYMB»java.util.Random«ENDSYMB» and Apache common's «SYMB»RandomGenerator«ENDSYMB» objects and more. 
          
          If the model has exactly one «SYMB»random«ENDSYMB» variable of type «SYMB»IntVar«ENDSYMB» or «SYMB»RealVar«ENDSYMB» then the 
          generate block should return an integer or double respectively, corresponding to the new realization. Otherwise, the generate block 
          should modify the «SYMB»random«ENDSYMB» variable(s) should be modified in place.
        '''
      ]
    ]
    section("XExpressions") [
      it += '''
        The syntax for XExpressions is provided by the Xtext language engineering framework.
        
        XExpressions are also used by Xtend, an expressive language built on top of Java providing 
        «LINK("https://www.eclipse.org/xtend/index.html")»"powerful macros, lambdas, operator overloading 
        and many more modern language features"«ENDLINK». We use Xtend to write some parts of the runtime machinery.
        
        We review the main aspects of XExpressions relevant 
        for writting Blang models here for completeness, 
        following the structure of the «LINK("http://www.eclipse.org/xtend/documentation/203_xtend_expressions.html")»official Xtend documentation«ENDLINK».
      '''
      section("Types") [
        it += '''Types can be categorized as follows:'''
        unorderedList[
          it += '''
            primitives, which are low-level building blocks. Those relevant here are 
            «SYMB»boolean«ENDSYMB», «SYMB»int«ENDSYMB» and «SYMB»double«ENDSYMB». 
            They work «LINK("https://docs.oracle.com/javase/tutorial/java/nutsandbolts/datatypes.html")»as in Java«ENDLINK»;
          '''
          it += '''
            object references; which can be thought of as an annotated address to a memory location (possibly «SYMB»null«ENDSYMB»);  
          '''
          it += '''
            array references. This last category is rarely directly used in Blang. 
            Instead, use higher level constructs provided by the Java SKD, such 
            as objects of type «SYMB»ArrayList«ENDSYMB», «SYMB»String«ENDSYMB». 
          '''
        ]
      ]
      section("Literals") [
        it += '''The following expressions create constants of various types:'''
        unorderedList[
          it += '''«SYMB»boolean«ENDSYMB»: «SYMB»true«ENDSYMB», «SYMB»false«ENDSYMB»'''
          it += '''«SYMB»int«ENDSYMB»: e.g. «SYMB»42«ENDSYMB», «SYMB»12_000«ENDSYMB»'''
          it += '''«SYMB»double«ENDSYMB»: make sure to add a decimal suffix, «SYMB»1.0«ENDSYMB», or the scientific notation «SYMB»1.3e2«ENDSYMB»'''
          it += '''type literals, e.g. «SYMB»String«ENDSYMB», which is equivalent to Java's «SYMB»String.class«ENDSYMB»'''
          it += '''«SYMB»List«ENDSYMB»: e.g. «SYMB»#[true, false]«ENDSYMB»'''
          it += '''«SYMB»Set«ENDSYMB»: e.g. «SYMB»#{"red", "blue", "green"}«ENDSYMB»'''
          it += '''«SYMB»Pair«ENDSYMB», with arbitrary key type and value type: e.g. «SYMB»"likelihood" -> -123.43«ENDSYMB»'''
          it += '''«SYMB»Map«ENDSYMB»: e.g. «SYMB»#{"key" -> 1 ,"key2" -> 2}«ENDSYMB»'''
        ]
      ]
      section("Declaring variables in XExpressions") [
        it += '''Some examples: '''
        code(Language.blang, '''
          val int myConstantInt = 17
          var String myModifiableInt
          var typeInferred = #[1, 2, 3]
        ''')
        it += '''
          In the first example, «SYMB»val«ENDSYMB» encodes that the variable cannot be changed (in the same sense as Java's final keyword for variables), while the other example 
          use «SYMB»var«ENDSYMB» encoding the fact the variable can be changed afterwards. 
          
          The meaning of immutability is simple to understand in the case of primitive, but it should be interpreted carefully
          in the context of references. In the latter, it means that the reference will always point to the same object in the heap, 
          however the internal state of that object might change over its life time.
          
          In the third line of the example, the type is inferred automatically (here as «SYMB»List<Integer>«ENDSYMB»). Such automatic type 
          inference is often, but 
          not always possible. We recommend avoiding this construct however to maintain readability.
        '''
      ]
      section("Conditionals") [
        it += '''
          Conditional expressions have the form 
        '''
        code(Language.blang, '''
          if (condition) {
            // do something
          }
        ''')
        it += '''Optionally, they can have an else clause. Also, the pair of if and else is an expression (i.e. returns a value)'''
        code(Language.blang, '''
          val String variable = if (condition) "firstString" else "secondString"
        ''')
        it += '''If else is not included, «SYMB»else null«ENDSYMB» is used implicitly to maintain an expression interpretation.'''
      ]
      section("Switch") [
        it += '''
          Instead of chaining several if and else, use a switch, which is significantly more functional than Java's, as it relies on 
          call «SYMB».equals«ENDSYMB» by default, and does not require calling «SYMB»break«ENDSYMB» after each clause:
        '''
        code(Language.blang, '''
          switch myString {
            case myString.isEmpty : "empty"
            case "match" : "the string is equal to 'match'"
            default : "This is a default case"
          }
        ''')
      ]
      section("Loops") [
        it += '''
          Several loop variants are allowed:
        '''
        unorderedList[
          it += '''
            High-level for loop, «SYMB»for (IteratorType iteratorName : range) { ... }«ENDSYMB», as in laws blocks but without restrictions on the range 
            being fixed during sampling, e.g «SYMB»for (String s : #["a", "b"]) { println(s) }«ENDSYMB». The type of the iterator 
            can be skipped (not recommended for readability). 
          '''
          it += '''
            Basic for loop, «SYMB»for (var IteratorType iteratorName = init; condition; update) { ... }«ENDSYMB», e.g. 
            «SYMB»for (var int i = 0; i <= 10; i++) { ... }«ENDSYMB».
          '''
          it += '''
            While loops, «SYMB»while (condition) { ... }«ENDSYMB».
          '''
          it += '''
            Do-while, where the body is executed at least once, «SYMB»do { ... } while (condition)«ENDSYMB».
          '''
        ]
      ]
      section("Function calls") [
        it += '''
          Functions are called as in most languages, i.e. «SYMB»nameOfFunction(expression1, expression2, ...)«ENDSYMB», where each 
          element in «SYMB»expression1, expression2, ...«ENDSYMB» are themselves XExpressions. These expressions are evaluated 
          first, then the results of these evaluations are passed in to the function ("eager evaluation", as in Java for example). 
          The only exception is the composite laws listed in «SYMB»laws { .. }«ENDSYMB», as described above, in which case evaluation 
          of the argument is delayed at initialization and instead repeated each time the density is evaluated during MCMC sampling 
          (a form of "lazy evaluation" in this unique special case). 
          
          In all cases, the actual function call only involves copying a constant size register so that function calls are always very 
          cheap. For primitives, the value of the primitive is copied (and hence the original primitive can never suffer side effects from 
          the call). For references, the memory address in the reference is copied (and hence the original reference cannot be changed, 
          although the object it points to might have its state changed by the function call). 
        '''
      ]
      section("User defined functions") [
        it += '''
          To create your own function, create a separate Java or Xtend file. In Java, use:
        '''
        code(Language.java, '''
          package my.pack;
          public class MyFunctions {
            public static ReturnType myFunction(ArgumentType1, arg1, ArgumentType2, arg2) {
              // some computation
              return result;
            }
          }
        ''')
        it += '''
          In Xtend:
        '''
        code(Language.xtend, '''
          package my.pack
          class MyFunctions {
            def static ReturnType myFunction(ArgumentType1, arg1, ArgumentType2, arg2) {
              // some computation
              return result 
            }
          }
        ''')
        it += '''
          Then, add «SYMB»import static my.pack.MyFunction.*«ENDSYMB» to your Blang file. You will now be able to call
          «SYMB»myFunction(arg1, arg2)«ENDSYMB».
        '''
      ]
      section("Creating objects") [
        it += '''
          Objects are created by writing «SYMB»new NameOfClass(argument1, ...)«ENDSYMB». This can be 
          shortened to «SYMB»new NameOfClass«ENDSYMB» if there are no arguments. 
          
          In some libraries, the call to new is wrapped inside a static function. In this case, 
          just call the function to instantiate the object.
        '''
      ]
      section("Using objects") [
        it += '''
          Classes have «EMPH»instance variables or field«ENDEMPH» (variables guaranteed to be available for a given type), as well as 
          «EMPH»(instance) methods«ENDEMPH» (functions associated with the object having access to the object's instance variables). 
          Collectively, fields and methods are called «EMPH»features«ENDEMPH». 
          
          Features are accessed using the "dot" notation: «SYMB»object.variable«ENDSYMB» and «SYMB»object.method(...)«ENDSYMB». When a 
          method has no argument, the call can be shortened to «SYMB»object.method«ENDSYMB». 
          
          The ability to call a feature is subject to 
          «LINK("https://docs.oracle.com/javase/tutorial/java/javaOO/accesscontrol.html")»Java visibility constraints«ENDLINK». 
          In short, only public features can be called from outside file declaring a class. 
        '''
      ]
      section("Implicit variables it") [
        it += '''
          The special variable «SYMB»it«ENDSYMB» allows to provide a default receiver for feature calls. For example:
        '''
        code(Language.blang, '''
          val it = someObject
          it.doSomething
          doSomething // equivalent short form
        ''')
      ]
      section("Lambda expression") [
        it += '''
          A "lambda expression" is an unfortunate name for a simple concept: a succinct way to write function without having to 
          give it a name. This makes it easy to call functions which take functions as argument (e.g. to apply the function to 
          each item in a list, etc). Since they are so useful, many syntactic shortcut are available. 
          
          Explicit syntax for lambda expressions is:
        '''
        code(Language.blang, '''
          [Type1 argument1, ... | functionBody ]
        ''')
        it += '''For example, to capitalize words in a list:'''
        code(Language.blang, '''
          #["one", "two"].map([String s | s.toUpperCase])
        ''')
        it += '''
          When there is a single input argument, you can skip declaring the argument, and instead the argument will be 
          assigned to «SYMB»it«ENDSYMB» (describe in the previous section). This allows us to write for example:
        '''
        code(Language.blang, '''
          #["one", "two"].map([toUpperCase])
        ''')
        it += '''
          Finally, when the last argument of a function is a function, you can simply put the lambda after the parentheses 
          of the function call. For example:
        '''
        code(Language.blang, '''
          #["one", "two"].map[toUpperCase]
        ''')
        it += '''
          Lambda expression can also access final variables (i.e. marked by «SYMB»val«ENDSYMB») that are in the scope. 
          
          Lambda expressions can be automatically cast to interfaces having a single declared method.
        '''
      ]
      section("Type casts") [
        it += '''
          Type casts work as in Java, but with a more readable syntax: «SYMB»aDoubleVariable as int«ENDSYMB» 
          instead of «SYMB»(int) aDoubleVariable«ENDSYMB».
        '''
      ]
      section("Boxing and unboxing") [
        it += '''
          Boxing refers to wrapping a primitive such as «SYMB»int«ENDSYMB» or «SYMB»double«ENDSYMB» into an object 
          such as «SYMB»Integer«ENDSYMB» or «SYMB»Double«ENDSYMB». Deboxing is the reverse process.  
          As in Java, the conversion between the two (boxing/deboxing) is 
          automatic in the vast majority of the cases.
          
          Blang adds boding/deboxing to and from «SYMB»IntVar«ENDSYMB» and «SYMB»RealVar«ENDSYMB».
        '''
      ]
      section("Scope") [
        it += '''
          The scope of a variable is the subset of the code in which it can be accessed. Scoping in Blang generally works 
          as in most programming language: to find the scope of a variable, identify the parent set of braces, these 
          determine the region of the code where the variable can be accessed. If one variable reference is in the scope of several 
          variables declared with the same name, the innermost set of braces has priority.
          
          The only exception are the arguments of the atomic and composite laws, which require explicit identification of the variables 
          to include in the scope. These variables to be included should be identified at the right of the «SYMB»|«ENDSYMB» symbol. 
          We make this modification because these scoping dependencies drive the inference of the sparsity patterns in the graphical model. 
        '''
      ]
      section("Operator overloading") [
        it += '''
          Operator overloading is permitted. One important case to be aware of is «SYMB»==«ENDSYMB» which is overloaded 
          to «SYMB».equals(..)«ENDSYMB». Use «SYMB»===«ENDSYMB» for the low-level equality operator that checks if the 
          two sides are identical (with the exception of «SYMB»Double.NaN«ENDSYMB», Not a Number, which following 
          IEEE convention is never equal to anything). 
          
          When in the Blang IDE, command click on an operator to reveal its definition.
          
          Some useful operators automatically imported:
        '''
        unorderedList[
          it += '''
            «SYMB»object => lambdaExpression«ENDSYMB»: calls the lambda expression with the input given by object, 
            e.g. «SYMB»new ArrayList => [add("to be added in list")]«ENDSYMB»
          '''
          it += '''
            range operators, for example «SYMB»0 .. 10«ENDSYMB», «SYMB»0 ..< 11«ENDSYMB», «SYMB»-1 >.. 10«ENDSYMB»; all these 
            examples return the integers «MATH»0, 1, 2, ..., 10«ENDMATH».
          '''
        ]
        it += '''  
          See the «LINK("http://www.eclipse.org/xtend/documentation/203_xtend_expressions.html")»Xtend documentation«ENDLINK» 
          if you want to overload operators in custom types.
        '''
      ]
      section("Extensions") [
        it += '''
          Extension methods provide a kind of lightweight trait, i.e. adding methods to existing classes on demand. 
          
          This is done by adding an extension import:
       '''
       code(Language.blang, '''import static extension my.namespace.myfunction''')
       it += '''
          You can then write «SYMB»arg1.myfunction(arg2, ...)«ENDSYMB» instead of «SYMB»myfunction(arg1, arg2, ...)«ENDSYMB».
       '''
      ]
      section("Parameterized types") [
        it += '''
          Types can be parameterized, for example to use Java's «SYMB»List«ENDSYMB» type, it is preferable to specify the 
          type that will stored in the list. For example to declare that strings will be stored, use «SYMB»List&lt;String&gt;«ENDSYMB» 
          as in Java or Xtend. 
          
          Models can use variables with type parameters but models themselves cannot have type parameters at the moment.
        '''
      ]
      section("Throwing exceptions") [
        it += '''
          Throw exceptions to signal abnormal behaviour and to terminate the Blang runtime with an informative message:
        '''
        code(Language.blang, '''
          throw new RuntimeException("Some error message.")
        ''')
        it += '''
          To signal that the current factor has invalid parameters: if possible just return the value -INFINITY, or if it is not 
          easy for a certain code structure, use instead «SYMB»blang.types.StaticUtils.invalidParameter«ENDSYMB», which will 
          be caught and interpreted as the factor having zero probability.
          
          In contrast to Java, exception are never required to be declared or caught. If they need to be caught, the syntax is:
        '''
        code(Language.blang, '''
          try {
            // code that might throw an exception
          } catch (ExceptionType exceptionName) {
            // process exception
          }
          // optionally:
          finally {
            // code executed whether the exception is thrown or not
          }
        ''')
      ]
      section("Other aspects not covered") [
        it += '''
          There are a few other aspects of XExpressions that we haven't covered here:
        '''
        unorderedList[
          it += '''
            the «SYMB»synchronized«ENDSYMB» keyword and a 
            «LINK("https://docs.oracle.com/javase/tutorial/essential/concurrency/")»rich parallelization library«ENDLINK»; 
          '''
          it += '''
            optional dispatch method, allowing to mix and match static and runtime method polymorphism;
          '''
          it += '''
            active annotation, which along with the reflection API, allows powerful meta-programming; 
          '''
          it += '''
            built-in string templates.
          '''
        ]
        it += '''Detailed description of these features can be found in the 
        «LINK("http://www.eclipse.org/xtend/documentation/203_xtend_expressions.html")»Xtend documentation«ENDLINK».'''
      ]
    ]
    section("Creating classes, interfaces, annotation interface and enumerations") [
      it += '''
        As customary, Java types should be created in separate files and imported into Blang models as needed. 
        The separate files can be written either in 
        «LINK("https://docs.oracle.com/javase/tutorial/java/index.html")»Java«ENDLINK» or in 
        «LINK("http://www.eclipse.org/xtend/documentation/202_xtend_classes_members.html")»Xtend«ENDLINK».
      '''
    ]
  ]
  
}