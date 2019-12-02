package machine;
using tink.CoreApi;
import haxe.ds.List;
import haxe.ds.Option;
using haxe.EnumTools.EnumValueTools;

enum StateCond{
   Sbool(b:Bool);
   Val(n:Any);
}

typedef Toz={
   state:StateBaseClass,
   cond:StateCond
}
typedef StateBaseClass=Class<StateBase>;

class FSM{

  public var currentStateId:String;
  public var prevStateId:String;

   var tozMap:Map<String,Array<Toz>>;
   var stateMap:Map<String,StateBase>;
   var curList:haxe.ds.List<String>;
   var iter:Iterator<String>;
   var payload:Any;

   public function new(){
      trace( "new");
      tozMap=[];
      stateMap=[];
      curList=new List();
   }

   public function add(s:StateBaseClass,toz:Array<Toz>){
        var id=generateId();
        var state=Type.createInstance(s,[id,this]);
        stateMap.set(id,state);
        
        tozMap.set(id,toz);

        curList.add(id);
        iter=curList.iterator(); 

   }

   public function answer(id,cond:StateCond){
      trace("answer " +id);
      
         switch(chooseToz(id,cond)){
            case Some(v):
                  trace("next is" + v);
                  
                  next();
            case None: 
               trace( "nope");
         }

   }

   function generateId():String{
      var alf="abcedfefghigjijbytvghgdysdsdd";
      var _id= "";
      for ( a in 0 ... 5){
         var r=Std.random(alf.length);
            _id+=alf.substr(r,1);
      }
      return _id;
   }

   public function chooseToz(id,cond:StateCond):Option<StateBaseClass>{
   var toz=tozMap.get(id);

   var ret:Option<StateBaseClass>=None;
      for ( a in toz){ 
         trace( "yo");
         ret= switch(a.cond){
            case Sbool(b):
               trace(a.cond +"="+cond);
               if(Type.enumEq(a.cond,cond)){
                  payload=b;
                return Some(a.state);
                  break;
               }
                None;
            case Val(b):
                  trace(a.cond +"="+cond);
                  trace(a.cond.getName());
                  trace(a.cond.getName() == cond.getName());
                  if(a.cond.getName()==cond.getName()){
                     payload=b;
                     return Some(a.state);
                   break;
               }
               None;
            
         }

      }
      return ret;
   }

   function getState(id:String):StateBase{
      return stateMap.get(id);
   }

   public function next(){
      trace( "next" +curList.length);
      if (iter.hasNext()){
         trace( "hasnext");
         currentStateId=iter.next();
         trace('currentStateId = $currentStateId');
         try{
            var curstate=getState(currentStateId);
         if( payload!=null)
         curstate.set_Payload(payload);
         curstate.enter();
         #if tested
         getState(currentStateId).resolve();
         #end
         }catch(msg:Any){
            trace(msg);
         }
      }
    //  var curd= currentState.id;
   }

   public function back(){

   }

}


interface IState{

}


@:allow(FSM)
class StateBase implements IState{

   var id:String; /// done by FSM
   var fsm:FSM;
   var payload:Promise<Dynamic>;
   var pt=Promise.trigger();
   private function new(id,fsm){
      this.id=id;
      this.fsm=fsm;
      payload=pt.asPromise();

   }
   public function set_Payload(n){
      payload=pt.resolve(n);
   }
   public function enter(){
      throw 'override me';
   }
   public function resolve():StateCond{
      //fsm.answer(true);
      throw 'override me';
   }



}