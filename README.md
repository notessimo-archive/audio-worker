# audio-worker

A wrapper over `golems` which create a worker that can generate audio buffer from arbitrary data

Currently that "data" is Bytes, I might make it more generic in the future but the idea was to have something very low level

Support vanilla js, swf and openfl.

Sample:
```haxe
// Create the AudioPlayer
var audio = AudioPlayer.create();

// Create an AudioWorker that will generates tons of noise on a worker
// We use 'Golems' to generate worker which are defined in a hxml
var worker = AudioWorker
    .create(Golem.rise('../hxml/NoiseWorker.hxml'), audio.bufferSamples, audio.sampleRate)
    .start();

// Play the resulting buffers in an AudioPlayer
audio
    .useGenerator(worker.generator)
    .play();
```

Worker:
```haxe
class NoiseWorker extends BasicWorker<AudioWorkerParams, Float32Array> {

    override function process( params : AudioWorkerParams ) {
        var buffer : Float32Array = new Float32Array( params.samples << 1 );

        for( i in 0...params.samples ) {
            var noise = Math.random() * 2 - 1;
            buffer.set(i << 1, noise);
            buffer.set(i << 1 + 1, noise);
        }

        return buffer;
    }
}
```