import machine.FSM;

import utest.Assert;

class RunAll{

   public static function main(){

      utest.UTest.run([
         new TestBase(),
         new TestOtherConds(),
         new TestFollow()
         ]);
   }

}
@:access(machine.FSM)
class TestBase extends utest.Test{
   var fsm:machine.FSM;
   function setup(){
      fsm= new FSM();
      fsm.add(MockStateA,[
         {cond:Sbool(false),state:MockStateB},
         {cond:Sbool(true),state:MockStateC}
         ]);
      fsm.add(MockStateC,[
         {cond:Sbool(false),state:MockStateA},
         {cond:Sbool(true),state:MockStateB}
         ]);
      fsm.add(MockStateB,[
         {cond:Sbool(true),state:MockStateA},
         {cond:Sbool(false),state:MockStateC}
         ]);
   }

   function testtest(){
      Assert.isTrue(1==1);
   }

   function testFindState(){
      var r= MockStateA;
     var state= fsm.getStateByClass(r);
      Assert.notNull(state);
   }

   function testnext(){     
      fsm.next();
      Assert.notNull(fsm.currentStateId);
   }

   function testAnswer(){
      fsm.next();
      Assert.equals(fsm.currentStateId,fsm.curList.last());
   }

   function teardown(){
      fsm=null;
   }

}

@:access(machine.FSM)
class TestOtherConds extends utest.Test{
   var fsm:machine.FSM;
   function setup(){
         fsm= new FSM();
         fsm.add(MockStateD,[
         {cond:Sbool(false),state:MockStateB},
         {cond:Val(null),state:MockStateA}
         ]);
         // fsm.add(MockStateA,[
         // {cond:Sbool(true),state:MockStateB},
         // ]);
   }

   function testValue(){
      fsm.next();
      Assert.equals(2,fsm.payload);
   }

}


@:access(machine.FSM)
class TestFollow extends utest.Test{
   var fsm:machine.FSM;
   function setup(){
         fsm= new FSM();
         fsm.following=true;

         fsm.add(MockStateD,[
         {cond:Sbool(false),state:MockStateB},
         {cond:Val(null),state:MockStateA}
         ]);

         // fsm.add(MockStateA,[
         // {cond:Sbool(true),state:MockStateB},
         // ]);
   }

   function testValue(){
      fsm.next();
      Assert.equals(2,fsm.payload);
   }

   function testFollow(){
      fsm.next();
      Assert.same(MockStateA,Type.getClass(fsm.getState(fsm.currentStateId)));
   }

}



class MockStateA extends machine.FSM.StateBase{

   function new(id,fsm){
      super(id,fsm);

   }

   override function resolve():StateCond{
      fsm.answer(id,Sbool(true));
      return Sbool(true);
   }

}

class MockStateB extends machine.FSM.StateBase{
   override function resolve():StateCond{
      fsm.answer(id,Sbool(true));
      return Sbool(true);
   }
}
class MockStateC extends machine.FSM.StateBase{
   override function resolve():StateCond{
      fsm.answer(id,Sbool(true));
      return Sbool(true);
   }
}

class MockStateD extends machine.FSM.StateBase{

   override function enter(payload){
      trace("enter mockstateD");
   }
   override function resolve():StateCond{
      trace( "mockstateD resolve");
      fsm.answer(id, Val(2) );
      return null;
   }
}