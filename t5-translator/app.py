from fastapi import FastAPI
from pydantic import BaseModel
from transformers import T5ForConditionalGeneration, T5Tokenizer

app = FastAPI()

model = T5ForConditionalGeneration.from_pretrained("t5-small")
tokenizer = T5Tokenizer.from_pretrained("t5-small")

class InputData(BaseModel):
    prompt: str
    language: str = "en"  # default language English

@app.get("/")
async def root():
    return {"status": "Model running"}

@app.post("/generate")
async def generate_text(data: InputData):
    language_prompts = {
        "en": "",
        "fr": "translate English to French: ",
        "de": "translate English to German: ",
        "es": "translate English to Spanish: ",
        "it": "translate English to Italian: ",
    }

    task_prefix = language_prompts.get(data.language, "")
    full_prompt = task_prefix + data.prompt

    input_ids = tokenizer.encode(full_prompt, return_tensors="pt")
    output_ids = model.generate(input_ids, max_length=100, do_sample=True)
    output = tokenizer.decode(output_ids[0], skip_special_tokens=True)

    return {"generated_text": output, "language": data.language}