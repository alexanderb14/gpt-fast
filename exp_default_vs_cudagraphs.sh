#!/bin/bash
set -x
set -e

# Common variables
OUT_DIR=exp_outs

mkdir -p $OUT_DIR

mkdir -p $OUT_DIR/inductor-default
mkdir -p $OUT_DIR/inductor-reduce-overhead

MODEL_REPO=meta-llama/Llama-2-7b-chat-hf

PROMPT='Models for speech recognition or for NLP are often trained on input tensors with variable sequence length. Variable length can be problematic for PyTorch caching allocator and can lead to reduced performance or to unexpected out-of-memory errors. If a batch with a short sequence length is followed by an another batch with longer sequence length, then PyTorch is forced to release intermediate buffers from previous iteration and to re-allocate new buffers. This process is time consuming and causes fragmentation in the caching allocator which may result in out-of-memory errors.'

# Run experiments
# ##################
# Run
for i in {1..1}; do
    # Default
    python generate.py --compile --checkpoint_path checkpoints/$MODEL_REPO/model.pth --prompt "$PROMPT" --compile_prefill --num_samples 100 \
    &> $OUT_DIR/inductor-default/$i.log

    # Reduce overhead
    python generate.py --compile --checkpoint_path checkpoints/$MODEL_REPO/model.pth --prompt "$PROMPT" --compile_prefill_reduce_overhead --num_samples 100 \
    &> $OUT_DIR/inductor-reduce-overhead/$i.log
done

# Aggregate Results
python collect_stats.py
