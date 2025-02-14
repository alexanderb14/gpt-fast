#!/bin/bash
set -x
set -e

# Common variables
OUT_DIR=exp_outs
mkdir -p $OUT_DIR
mkdir -p $OUT_DIR/inductor-default
mkdir -p $OUT_DIR/inductor-reduce-overhead
MODEL_REPO=meta-llama/Llama-2-7b-chat-hf

export CUDA_VISIBLE_DEVIES=3

PROMPT='Models for speech recognition or for NLP are often trained on input tensors with variable sequence length. Variable length can be problematic for PyTorch caching allocator and can lead to reduced performance or to unexpected out-of-memory errors. If a batch with a short sequence length is followed by an another batch with longer sequence length, then PyTorch is forced to release intermediate buffers from previous iteration and to re-allocate new buffers. This process is time consuming and causes fragmentation in the caching allocator which may result in out-of-memory errors.'

# Run experiments
# ##################
# Run
for WORD_COUNT in {1..100}; do
    echo "Processing length $WORD_COUNT"
    echo "-----------------------------"

    # Extract the first WORD_COUNT words from the PROMPT
    CURRENT_PROMPT=$(echo $PROMPT | awk '{for(i=1;i<='$WORD_COUNT';i++) printf $i" "; print ""}')
    echo $CURRENT_PROMPT
    # Default
    python generate.py --compile --checkpoint_path checkpoints/$MODEL_REPO/model.pth --prompt "$CURRENT_PROMPT" --compile_prefill --num_samples 50 \
    &> $OUT_DIR/inductor-default/$WORD_COUNT.log
    # Reduce overhead
    python generate.py --compile --checkpoint_path checkpoints/$MODEL_REPO/model.pth --prompt "$CURRENT_PROMPT" --compile_prefill_reduce_overhead --num_samples 50 \
    &> $OUT_DIR/inductor-reduce-overhead/$WORD_COUNT.log
done
# Aggregate Results
python collect_stats.py
