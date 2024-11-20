// La Parrila del Nuevo Miguelito

// 1. COMIDAS

class Plato {
  
  method peso()

  method esAptoCeliaco()

  method valoracion()

  method esEspecial() = self.peso() > 250

  method precio() = self.valoracion() * 300 + if(self.esAptoCeliaco()) 1200 else 0
}

class Provoleta inherits Plato {
  const pesoProvoleta   // cada provoleta tiene un peso diferente
  const tieneEmpanado   // pueden tener o no empanado

  override method peso() = pesoProvoleta

  //method tieneEmpanado() = tieneEmpanado

  override method esAptoCeliaco() = !tieneEmpanado

  override method esEspecial() = super() and tieneEmpanado

  override method valoracion() = if(self.esEspecial()) 120 else 80
}

class HamburguesaSimple inherits Plato {
  const pesoMedallon    // El medallón de carne no siempre pesa lo mismo entre una hamburguesa y otra.
  const pan             // Cada hamburguesa puede hacerse con diferentes panes

  override method peso() = self.pesoMedallon() + pan.pesoPan()

  method pesoMedallon() = pesoMedallon

  override method esAptoCeliaco() = pan.esAptoCeliaco()   // Una hamburguesa es apta para celíacos según el pan con que estén hechas. (le paso la pelota al pan..)

  override method valoracion() = self.peso() / 10

  //override method esEspecial() = self.peso() > 250  // Nuevamente...!!, se considera especial cuando su peso es mayor a 250 gramos.
}

class HamburguesaDoble inherits HamburguesaSimple {
  
  override method pesoMedallon() = pesoMedallon * 2  // Pero en vez de uno tiene dos medallones de carne, siempre del mismo peso.

  override method esEspecial() = self.peso() > 500

  //override method valoracion() = self.peso() / 10 ---> Se calcula igual que la HamburguesaSimple
}

// PANES (aplico Polimorficamente)
object panIndustrial {
  method pesoPan() = 60
  method esAptoCeliaco() = false
}

object panCasero {
  method pesoPan() = 100
  method esAptoCeliaco() = false
}

object panDeMaiz {
  method pesoPan() = 30
  method esAptoCeliaco() = true
}

// Tambien se podria hacer asi la idea de los panes
class Pan {
  var property pesoPan
  var property esAptoCeliaco
}

//const panIndustrial = new Pan(pesoPan = 60, esAptoCeliaco = false)
//const panCasero = new Pan(pesoPan = 100, esAptoCeliaco = false)
//const panDeMaiz = new Pan(pesoPan = 30, esAptoCeliaco = true)

// ---------------------------------

class CorteDeCarne inherits Plato {
  var aPunto
  //var estado
  const pesoCarne

  //method estado() = estado

  override method peso() = pesoCarne

  override method esEspecial() = super() and aPunto  // se considera especial si su peso es mayor a 250 gramos, como los otros platos, y está a punto.

  override method esAptoCeliaco() = true

  override method valoracion() = 100
}

class Parrillada inherits Plato {
  const comidas = []  // Una parrillada esta compuesta por varias comidas

  override method peso() = comidas.sum({plato => plato.peso()})

  override method esEspecial() = super() and self.cantidadPlatos() >= 3

  method cantidadPlatos() = comidas.size()

  override method esAptoCeliaco() = comidas.all({plato => plato.esAptoCeliaco()}) // Si alguna de las cosas que incluye no es apta para celíacos, la parrillada tampoco lo es. (es decir, todos los platos que componen a la parrillada tienen que ser aptos celiacos)

  override method valoracion() = comidas.max({plato => plato.valoracion()}) // Su valoración es la mayor valoración de todo lo que la compone.
}

// 2. COMENSALES

class Comensal {
  var dineroDisponible
  var habitoDeAlimentacion  // A un comensal empieza a tener problemas gástricos y le descubren celiaquía, con lo que modifica sus hábitos de alimentación

  method leAgrada(comida) = habitoDeAlimentacion.leAgrada(comida) 

  method darUnGusto() {
    //const platoAComprar = miguelito.platoConMayorValoracion()
    self.leAgradaAlgunPlatoDeLaParrilla()   // 1ero chequeo si le agrada algun plato, si es asi, que verifique que se fije si puede pagar el plato con mayor valoracion  
    //self.leAgradaElPlato(platoAComprar)
    //self.puedePagar(platoAComprar)
    //self.comprarPlato(platoAComprar)
  }

  method leAgradaElPlato(plato) {
    if(!self.leAgrada(plato))
      throw new DomainException(message = "El comensal NO le agrada el plato")
  }

  method leAgradaAlgunPlatoDeLaParrilla() {
    if(self.platosQueLeAgradanDelaParrilla().isEmpty()) // si esta vacio
      throw new DomainException(message = "El comensal NO le agrada ningun plato ofrecido por la parrilla de miguelito")
    else
      self.puedePagar(miguelito.platoConMayorValoracion())
  }

  method platosQueLeAgradanDelaParrilla() = miguelito.platosOfrecidosQueLeAgradanA(self)

  method puedePagar(plato) {
    if(dineroDisponible < plato.precio())
      throw new DomainException(message = "El comensal no tiene dinero suficiente para comprar el plato")
    else
      self.comprarPlato(plato)
  }

  method comprarPlato(plato) {
    dineroDisponible -= plato.precio()
    miguelito.venderPlato(plato)
    miguelito.agregarComensal(self)
  }

  method recibirRegalo(cantidad) {
    dineroDisponible += cantidad
  }
 
  method habitoDeAlimentacion() = habitoDeAlimentacion

  method cambiarHabito(newhabito) {
    habitoDeAlimentacion = newhabito
  }

  method puedeCambiarTodoTerreno() = habitoDeAlimentacion.puedeCambiarTodoTerreno()

  method esTodoTerreno() = habitoDeAlimentacion.esTodoTerreno()

}

object celiaco {
  method leAgrada(comida) = comida.esAptoCeliaco()
  method puedeCambiarTodoTerreno() = false
  method esTodoTerreno() = false
}

object dePaladarFino {
  method leAgrada(comida) = comida.esEspecial() or comida.valoracion() > 100
  method puedeCambiarTodoTerreno() = true
  method esTodoTerreno() = false
}

object todoTerreno {
  method leAgrada(comida) = true // nada le desagrada
  method puedeCambiarTodoTerreno() = false
  method esTodoTerreno() = true
}

object miguelito {
  var ingreso = 0
  const property platosOfrecidos = []
  const comensalesQueComieron = []

  method platoConMayorValoracion() = platosOfrecidos.max({plato => plato.valoracion()})

  method platosOfrecidosQueLeAgradanA(comensal) = platosOfrecidos.filter({plato => comensal.leAgrada(plato)})

  method venderPlato(plato) {
    ingreso += plato.precio()
  }

  method agregarComensal(comensal) {
    comensalesQueComieron.add(comensal)
  }

  method agregarPlato(plato) {
    platosOfrecidos.add(plato)
  }

  method hacerPromocion(cantidadDinero) {
    comensalesQueComieron.forEach({comensal => comensal.recibirRegalo(cantidadDinero)})
  }
}

// 3. CAMBIOS DE HABITOS

object gobierno {
  const habitantes = []
  
  method decisionEconomica() {
    self.habitantesAptosCambio().forEach({habitante => habitante.cambiarHabito(todoTerreno)})
  }

  method habitantesAptosCambio() = habitantes.filter({habitante => habitante.puedeCambiarTodoTerreno()}) 

  method agregarHabitante(newHabitante) {
    habitantes.add(newHabitante)
  }

  method sonHabitantesDeTodoTerreno() = habitantes.all({habitante => habitante.esTodoTerreno()})
}