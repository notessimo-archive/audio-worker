# audio-worker

A wrapper over `golems` which create a worker that can generate audio buffer from arbitrary data

Support vanilla js, swf and openfl.

Sample using no data:
```haxe
// Create the AudioPlayer
var audio = AudioPlayer.create();

// Create the AudioWorker
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
class NoiseWorker extends BasicWorker<AudioWorkerParams<Void>, Float32Array> {

    override function process( params : AudioWorkerParams<Void> ) {
        var buffer : Float32Array = new Float32Array( params.samples << 1 );

        for( i in 0...params.samples ) {
            var noise = Math.random() * 2 - 1;
            buffer.set(i << 1, noise); // Left
            buffer.set(i << 1 + 1, noise); // Right
        }

        return buffer;
    }
}
```

Sample using Float as data:

Notice the `requestBufferUsing` which return the frequency that is sent to the worker
```haxe
// Array of frequencies
var frequency = [425.0, 200.0, 500.0, 340.0, 100.0, 50.0, 400.0];

// Create the AudioPlayer
var audio = AudioPlayer.create();

// Create the AudioWorker
var worker = AudioWorker
    .create(Golem.rise('../hxml/SinWorker.hxml'), audio.bufferSamples, audio.sampleRate)
    .requestBufferUsing((position) -> frequency[position % frequency.length])
    .start();

// Play the resulting buffers in an AudioPlayer
audio
    .useGenerator(worker.generator)
    .play();
```

Worker:
```haxe
class SinWorker extends BasicWorker<AudioWorkerParams<Float>, Float32Array> {

    var n = 0;

    override function process( params : AudioWorkerParams<Float> ) {
        var buffer : Float32Array = new Float32Array( params.samples << 1 );

        var volume = 0.25;
        for( i in 0...params.samples ) {
            var sin = MathUtils.sin(2 * MathUtils.PI * n++ * params.data / params.sampleRate) * volume;
            buffer.set(i << 1, sin); // Left
            buffer.set(i << 1 + 1, sin); // Right
        }

        return buffer;
    }
}
```

Of course these are just examples, in a real world scenario you would probably want to send low-level data instructions like mix sample A at C5 at position 300, etc...