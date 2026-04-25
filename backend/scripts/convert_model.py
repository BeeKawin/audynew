import tensorflow as tf
import onnx
from pathlib import Path

"""
Convert TFLite emotion model to ONNX format for server deployment.
Run this script once to generate model.onnx
"""


def convert_tflite_to_onnx(tflite_path: str, onnx_path: str):
    """Convert TFLite model to ONNX format."""

    # Load TFLite model
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()

    # Get input/output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    print(f"Input shape: {input_details[0]['shape']}")
    print(f"Output shape: {output_details[0]['shape']}")
    print(f"Input dtype: {input_details[0]['dtype']}")

    # For TFLite to ONNX, we use tf2onnx
    # Alternative: use onnxruntime-tools or directly save as savedmodel then convert

    # Create a simple SavedModel from TFLite for conversion
    @tf.function(
        input_signature=[tf.TensorSpec(shape=[1, 48, 48, 3], dtype=tf.float32)]
    )
    def infer(input_tensor):
        interpreter.set_tensor(input_details[0]["index"], input_tensor)
        interpreter.invoke()
        output = interpreter.get_tensor(output_details[0]["index"])
        return output

    # Save as SavedModel
    saved_model_path = tflite_path.replace(".tflite", "_savedmodel")
    tf.saved_model.save(
        tf.Module(), saved_model_path, signatures={"serving_default": infer}
    )

    # Convert to ONNX using tf2onnx
    import tf2onnx

    model_proto, external_tensor_storage = tf2onnx.convert.from_saved_model(
        saved_model_path, opset=13, output_path=onnx_path
    )

    print(f"Model converted successfully: {onnx_path}")

    # Verify
    model = onnx.load(onnx_path)
    onnx.checker.check_model(model)
    print("ONNX model verified successfully!")


if __name__ == "__main__":
    # Paths
    tflite_model = Path("../../audy_app/assets/models/model.tflite")
    onnx_output = Path("models/model.onnx")

    # Ensure output directory exists
    onnx_output.parent.mkdir(exist_ok=True)

    convert_tflite_to_onnx(str(tflite_model), str(onnx_output))
