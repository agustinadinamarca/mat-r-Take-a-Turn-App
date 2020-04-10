
Model Status {
    String date
    Array<Integer> turnos value([20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20]) 
}

Experience Welcome {
    String title value("Take a Turn!") as Label
    String logo value("https://imgur.com/CId7sQ1.png") as Image
}

Experience loging {
    String name label("Name") as TextField
    String lastname label("Lastname") as TextField
    String dni label("DNI") as TextField
    Integer age label("Age") as TextField
    Integer number label("Telephone") as TextField
    String email1 label("Email") as TextField
    String turn as Label
    Integer index
    Decision btn action("MainContext.take") label("Take")
}

Experience Today {
    String date as Label
    String numDisponiblesToday value("") as Label
    Array<String> turns value([]) as Select 
    Array<String> turnsB 
    
    Decision btn action("MainContext.takeTurn") label("Take Turn")
    
    OnResume {
        Today exp = broker.ui.getDataSource()
        
        // Fecha
        DateFormatter df = DateFormatter(format:"dd-MM-yyyy")
        Date d = Date()
        exp.date = df.stringFromDate(d)
        
        // Actualizo etiqueta de turnos disponibles
        Filter f = Filter(modelName:"Status")
        f.equalTo("date", s.date)
        Array<Status> ass = broker.cloudPersistence.getWithFilter(f)
        
        Integer i = 0
        
        for k in ass.get(0).turnos {
            i = i + k
        }
        
        disponibles = i
        
        exp.numDisponiblesToday = "There are "+ disponibles.toString() + " turns available."
        
        exp.turns = ["Show All"]
        
        exp.turnsB = ["Show All", "09:00 h", "09:20 h", "09:40 h", "10.00 h", "10:20 h", "10:40 h", "11:00 h", "11:20 h", "11:40 h", "12:00 h", "12:20 h", "12:40 h", "13:00 h", "13:20 h", "13:40 h", "14:00 h", "14:20 h", "14:40 h", "15:00 h", "15:20 h", "15:40 h", "16:00 h", "16:20 h", "16:40 h", "17:00 h", "17:20 h", "17:40 h", "18:00 h"]
                
        Integer count = 0
        
        for i in exp.turnsB {
            if(count>0){
                String lab = i + ", " + ass.get(0).turnos.get(count-1).toString() + " available"
                exp.turns.add(lab)
            }
            
            ++count
        }
    
    }
}

Model Person {
    String name
    String lastname
    String dni
    String email
    Integer number
    Integer age
    Date date
    String turn
}

Module MainModule {
    void func(Timer t){
        Today exp = Today()
        
        // Fecha
        DateFormatter df = DateFormatter(format:"dd-MM-yyyy")
        Date d = Date()
        exp.date = df.stringFromDate(d)
        
        // Actualizo etiqueta de turnos disponibles
        Filter f = Filter(modelName:"Status")
        f.equalTo("date", s.date)
        Array<Status> ass = broker.cloudPersistence.getWithFilter(f)
        
        Integer i = 0
        
        for k in ass.get(0).turnos {
            i = i + k
        }
        
        disponibles = i
        
        exp.numDisponiblesToday = "There are "+ disponibles.toString() + " turns available."
        
        exp.turns = ["Show All"]
        
        exp.turnsB = ["Show All", "09:00 h", "09:20 h", "09:40 h", "10.00 h", "10:20 h", "10:40 h", "11:00 h", "11:20 h", "11:40 h", "12:00 h", "12:20 h", "12:40 h", "13:00 h", "13:20 h", "13:40 h", "14:00 h", "14:20 h", "14:40 h", "15:00 h", "15:20 h", "15:40 h", "16:00 h", "16:20 h", "16:40 h", "17:00 h", "17:20 h", "17:40 h", "18:00 h"]
                
        Integer count = 0
        
        for i in exp.turnsB {
            if(count>0){
                String lab = i + ", " + ass.get(0).turnos.get(count-1).toString() + " available"
                exp.turns.add(lab)
            }
            
            ++count
        }
        
        
        broker.ui.push("Today", exp)
    }
}


RuleContext MainContext {
    Rule take {
        loging exp = broker.ui.getDataSource()
        if(exp.name!=null&&exp.lastname!=null&&exp.dni!=null&&exp.email1!=null&&exp.number!=null&&exp.age!=null){
            
                Person p = Person()
                p.name = exp.name
                p.lastname = exp.lastname
                p.dni = exp.dni
                p.email = exp.email1
                p.number = exp.number
                p.age = exp.age
                p.turn = exp.turn
                p.date = Date()
                
                broker.cloudPersistence.save(p)
                
                //modifico status
                
                Filter f = Filter(modelName:"Status")
                f.equalTo("date", s.date)
                Array<Status> ass = broker.cloudPersistence.getWithFilter(f)
                
                
                Integer valuee = ass.get(0).turnos.get(exp.index)
                broker.cloudPersistence.remove(ass.get(0))
                ass.get(0).turnos.set(exp.index, valuee-1)
                broker.cloudPersistence.save(ass.get(0))
                
                
                
                broker.ui.showAlert("", "¡Te estaremos esperando hoy!")
                broker.ui.dismiss()
                
        }
    }
    
    Rule takeTurn {
        Today exp = broker.ui.getDataSource()
        // Veo horario seleccionado
        Integer index = exp.turns.selected().get(0)
        if(index!=0){
        
            Filter f = Filter(modelName:"Status")
            f.equalTo("date", s.date)
            Array<Status> ass = broker.cloudPersistence.getWithFilter(f)
            
            if(ass.get(0).turnos.get(index-1)>0){
            
                String turn = exp.turnsB.get(index) // le paso el horario seleccionado
                loging l = loging()
                l.turn = "Today turn: " + turn
                l.index = index-1
                broker.ui.present("loging", l)
            
            }else{
                broker.ui.showAlert("", "No turns available, please select other time.")
            }
        }

    }
}

Application {
    Integer totalPeopleByTurn
    Integer disponibles
    
    Status s
    
    Timer t
    
    OnInit {
        s = Status()
        
        DateFormatter df = DateFormatter(format: "dd-MM-yyy")
        s.date = df.stringFromDate(Date())
        
        broker.cloudPersistence.save(s)
        
        Filter f = Filter(modelName:"Status")
        f.equalTo("date", s.date)
        
        Array<Status> ass = broker.cloudPersistence.getWithFilter(f)
        if(ass.size()>1){
            broker.cloudPersistence.remove(ass.get(ass.size()-1))
        }
        
        totalPeopleByTurn = 20
        
        t = Timer(delay:1, function:@function(MainModule.func), repeat:false)
        t.start()
        Welcome w = Welcome()
        broker.ui.push("Welcome", w)
    }
}