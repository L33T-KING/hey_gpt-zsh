hgpt() {
    local prompt="$*"
    local gpt=$(curl https://api.openai.com/v1/chat/completions -s \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
            \"model\": \"gpt-4-0613\",
            \"messages\": [{\"role\": \"user\", \"content\": \"$prompt\"}],
            \"temperature\": 0.7,
            \"stream\": true
        }")

    while IFS= read -r text; do
        if [[ "$text" == 'data: [DONE]' ]]; then
            break
        elif [[ "$text" =~ "role" ]]; then
            continue
        elif [[ "$text" =~ "content" ]]; then
            echo -n "$text" | sed 's/data: //' | jq -r -j '.choices[0].delta.content'
        else
            continue
        fi
    done <<< "$gpt"
    echo
}
