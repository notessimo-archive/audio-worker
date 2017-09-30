typedef AudioWorkerParams<T> = {
    var samples : Int;
    var sampleRate : Float;
    @:optional var data : T;
}