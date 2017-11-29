package blang.runtime.internals.doc.components


import static blang.runtime.internals.doc.html.Tags.*
import java.util.List
import org.eclipse.xtend.lib.annotations.Data
import briefj.BriefIO
import java.io.File
import blang.runtime.internals.doc.contents.Quick_Start

@Data
abstract class Page {
  
  def String name() { // later: optional category from enum which is used in priority in menu
    this.class.simpleName.replace("_", " ")  
  }
  
  def String fileName() {
    name.replaceAll(" ", "_") + ".html"
  }
  
  def abstract Object contents()
  
  static final List<Page> pages = #[new Quick_Start]
  
  def private navLink(boolean isActive) {
    li [
      role = "presentation"
      if (isActive) {
        cla = "active"
      }
      a [href = fileName
        in += name
      ]
    ]
  }
  
  def private navBar() { 
    div [
      cla = "header clearfix"
      nav [
        ul [cla = "nav nav-pills pull-right"
          for (page : pages) {
            in += navLink(page === this)
          }
        ]
      ]
      in += h3 [
        cla = "text-muted"
        in += "Blang Doc"
      ]
    ]
  }
  
  def private page() {
    div [
      cla = "container"
      in += navBar
      in += contents
    ]
  }
    
  def private header() {
    '''
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
        <meta name="description" content="Blang documentation">
    
        <title>«name»</title>
    
        <link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet">
      
        <!-- Bootstrap core CSS -->
        <link href="dist/css/bootstrap.min.css" rel="stylesheet">
    
        <!-- Custom styles for this template -->
        <link href="jumbotron-narrow.css" rel="stylesheet">
    
        <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
        <!--[if lt IE 9]>
          <script src="https://oss.maxcdn.com/html5shiv/3.7.3/html5shiv.min.js"></script>
          <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
        <![endif]-->
      </head>
    '''
  }
  
  override toString() {
    '''
      <!DOCTYPE html>
      
      <!-- Warning This page was generated by «this.class.simpleName». Do not edit directly! -->
      
      <html lang="en">
        «header»
      
        <body>
      
          «page»
          
          <!-- Placed at the end of the document so the pages load faster -->
          <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js"></script>
          <script>window.jQuery || document.write('<script src="assets/js/vendor/jquery.min.js"><\/script>')</script>
          <script src="dist/js/bootstrap.min.js"></script>
          
        </body>
      </html>
    '''
  }
  
  def static void main(String [] args) {
    for (page : pages) {
      BriefIO.write(new File(page.fileName), page.toString)
    }
  }
  
}