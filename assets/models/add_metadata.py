import tflite_support.metadata as metadata
from tflite_support.metadata_schema_py_generated import ModelMetadataT

# Load the TFLite model
model_path = "model.tflite"  # Change this if needed
new_model_path = "model_with_metadata.tflite"

# Define metadata
model_metadata = metadata.MetadataPopulator.with_model_file(model_path)
metadata_info = metadata.ModelMetadataT()
metadata_info.name = "Plant Disease Detection"
metadata_info.description = "A model to classify plant diseases using TFLite."
metadata_info.version = "1.0"
metadata_info.author = "Your Name"
metadata_info.license = "MIT"

# Attach metadata to the model
model_metadata.load_metadata_buffer(metadata_info)
model_metadata.populate()

# Save the new model
with open(new_model_path, "wb") as f:
    f.write(model_metadata.get_model_buffer())

print("✅ Metadata added successfully!")
