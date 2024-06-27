from googletrans import Translator
import sys

if len(sys.argv) < 2:
    print('Usage: python translate.py <lang> <text>')
    sys.exit(1)

lang = sys.argv[1]

words = sys.argv[2:]
sentence = ' '.join(words)

translator = Translator()

# translate from English to Spanish
res = translator.translate(sentence, dest=lang)

print(res.text)
