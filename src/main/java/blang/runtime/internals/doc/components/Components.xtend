package blang.runtime.internals.doc.components

import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

class Components {
  
  def static section(Procedure1<Section> init) { new Section => init }
  
}