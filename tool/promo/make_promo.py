"""Builds the Flame Gallery announcement assets from simulator recordings.

Outputs (in --out):
  promo.mp4   1080x1920 vertical video with the demo track as soundtrack
  poster.png  1080x1350 announcement poster
  og.png      1200x630 social preview for the website

Inputs:
  --clips   folder with raw_slice.mp4, raw_runner.mp4, raw_match.mp4,
            raw_rhythm.mp4 (e.g. `xcrun simctl io booted recordVideo`)
  --shots   folder with fruit_slice.png, runner.png, sweet_swap.png,
            note_rush.png (gallery screenshots)
  --brand   screenshot of a branded start panel
  --song    soundtrack (apps/example/assets/audio/note_rush_demo.mp3)

Re-record by hand for the final cut and adjust CLIPS start/length below.
Needs Python 3 + Pillow and ffmpeg on PATH.
"""
import argparse
import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H = 1080, 1920
FPS = 30
AVENIR = '/System/Library/Fonts/Avenir Next.ttc'
MONO = '/System/Library/Fonts/SFNSMono.ttf'
BOLD, DEMI, MEDIUM, HEAVY = 0, 2, 5, 8

BG_TOP = (24, 20, 52)
BG_BOTTOM = (60, 34, 96)
PRIMARY = (167, 167, 255)
ACCENT = (255, 140, 90)
WHITE = (245, 244, 255)
MUTED = (190, 186, 220)

# name, source clip, start (s), length (s), title, caption
CLIPS = [
    ('slice', 'raw_slice.mp4', 36.0, 4.0, 'Fruit Slice', 'Swipe to slice. Avoid the bombs.'),
    ('runner', 'raw_runner.mp4', 10.0, 4.5, 'Ruins Runner', 'Three lanes. Swipe, jump, slide.'),
    ('match', 'raw_match.mp4', 6.0, 4.5, 'Sweet Swap', 'Match three. Chain cascades.'),
    ('rhythm', 'raw_rhythm.mp4', 20.0, 4.0, 'Note Rush', 'Tap the lanes on the beat.'),
]
INTRO, BRAND, OUTRO, FADE = 2.6, 3.0, 3.4, 0.4

PHONE_H = 1380
PHONE_W = round(PHONE_H * 1206 / 2622)
PHONE_X = (W - PHONE_W) // 2
PHONE_Y = 420
PHONE_R = 64


def font(size, face=BOLD):
    return ImageFont.truetype(AVENIR, size, index=face)


def gradient(w, h):
    img = Image.new('RGB', (w, h))
    px = img.load()
    for y in range(h):
        t = y / (h - 1)
        c = tuple(int(BG_TOP[i] + (BG_BOTTOM[i] - BG_TOP[i]) * t) for i in range(3))
        for x in range(w):
            px[x, y] = c
    glow = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    d = ImageDraw.Draw(glow)
    d.ellipse([w * 0.55, -h * 0.1, w * 1.3, h * 0.45], fill=ACCENT + (70,))
    d.ellipse([-w * 0.4, h * 0.55, w * 0.5, h * 1.1], fill=PRIMARY + (60,))
    glow = glow.filter(ImageFilter.GaussianBlur(min(w, h) // 6))
    img = img.convert('RGBA')
    img.alpha_composite(glow)
    return img


def centered(d, y, text, f, fill):
    width = d.textlength(text, font=f)
    d.text(((d.im.size[0] - width) / 2, y), text, font=f, fill=fill)


def pill(d, cx, y, text, f, fg, bg, pad=(28, 14)):
    width = d.textlength(text, font=f)
    box = [cx - width / 2 - pad[0], y, cx + width / 2 + pad[0], y + f.size + pad[1] * 2]
    d.rounded_rectangle(box, radius=(box[3] - box[1]) / 2, fill=bg)
    d.text((cx - width / 2, y + pad[1] - f.size * 0.12), text, font=f, fill=fg)


def phone_window(base):
    """Background with a rounded transparent hole + bezel where the clip shows."""
    img = base.copy()
    mask = Image.new('L', (W, H), 255)
    ImageDraw.Draw(mask).rounded_rectangle(
        [PHONE_X, PHONE_Y, PHONE_X + PHONE_W, PHONE_Y + PHONE_H], radius=PHONE_R, fill=0)
    img.putalpha(mask)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(
        [PHONE_X - 14, PHONE_Y - 14, PHONE_X + PHONE_W + 14, PHONE_Y + PHONE_H + 14],
        radius=PHONE_R + 14, outline=(12, 10, 24), width=16)
    return img


def game_card(title, caption, index):
    img = gradient(W, H)
    d = ImageDraw.Draw(img)
    pill(d, W / 2, 120, f'{index} / 4', font(30, DEMI), (20, 18, 40), PRIMARY)
    centered(d, 200, title, font(92, HEAVY), WHITE)
    centered(d, 320, caption, font(40, MEDIUM), MUTED)
    return phone_window(img)


def code_box(d, x, y, lines, f, width):
    h = len(lines) * (f.size + 18) + 44
    d.rounded_rectangle([x, y, x + width, y + h], radius=28, fill=(14, 12, 28))
    for i, (txt, col) in enumerate(lines):
        d.text((x + 36, y + 24 + i * (f.size + 18)), txt, font=f, fill=col)
    return h


def intro_card():
    img = gradient(W, H)
    d = ImageDraw.Draw(img)
    pill(d, W / 2, 560, 'NEW · Flutter + Flame', font(34, DEMI), (20, 18, 40), ACCENT)
    centered(d, 680, 'Flame Gallery', font(128, HEAVY), WHITE)
    centered(d, 850, 'Drop-in mini games', font(56, DEMI), PRIMARY)
    centered(d, 925, 'for your Flutter app', font(56, DEMI), PRIMARY)
    centered(d, 1060, 'Slice · Runner · Match-3 · Rhythm', font(40, MEDIUM), MUTED)
    return img


def brand_card(brand_shot):
    img = gradient(W, H)
    d = ImageDraw.Draw(img)
    centered(d, 150, 'Your brand.', font(96, HEAVY), WHITE)
    centered(d, 270, 'Your colors, art, texts and rules.', font(42, MEDIUM), MUTED)
    shot = Image.open(brand_shot).convert('RGB')
    sh = 1000
    sw = round(sh * shot.width / shot.height)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    mask = Image.new('L', (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw, sh], radius=48, fill=255)
    x = (W - sw) // 2
    img.paste(shot, (x, 400), mask)
    mono = ImageFont.truetype(MONO, 32)
    code_box(d, 90, 1450, [
        ('FruitSlice(', WHITE),
        ('  theme: GameTheme(colorScheme: brand),', PRIMARY),
        ("  strings: FruitSlice.stringsTr,", PRIMARY),
        ('  config: SliceConfig(timeLimit: 30.s),', PRIMARY),
        (')', WHITE),
    ], mono, W - 180)
    return img


def outro_card():
    img = gradient(W, H)
    d = ImageDraw.Draw(img)
    centered(d, 520, 'One call.', font(110, HEAVY), WHITE)
    mono = ImageFont.truetype(MONO, 34)
    code_box(d, 80, 720, [
        ('flutter pub add flame_gallery', ACCENT),
    ], mono, W - 160)
    code_box(d, 80, 880, [
        ('final result = await FlameGallery.show(', WHITE),
        ('  context,', WHITE),
        ('  game: const FruitSlice(),', PRIMARY),
        (');', WHITE),
    ], mono, W - 160)
    centered(d, 1260, 'pub.dev/packages/flame_gallery', font(44, DEMI), WHITE)
    centered(d, 1330, 'vb10.github.io/flame_gallery', font(44, DEMI), PRIMARY)
    centered(d, 1440, 'MIT · iOS · Android · Web', font(36, MEDIUM), MUTED)
    return img


def ff(*args):
    subprocess.run(['ffmpeg', '-loglevel', 'error', '-y', *args], check=True)


def still_segment(png, seconds, out):
    ff('-loop', '1', '-t', str(seconds), '-i', str(png),
       '-vf', f'fps={FPS},format=yuv420p', '-c:v', 'libx264', '-pix_fmt', 'yuv420p', str(out))


def clip_segment(src, start, length, overlay_png, out):
    ff('-ss', str(start), '-t', str(length), '-i', str(src), '-loop', '1', '-i', str(overlay_png),
       '-filter_complex',
       f'color=c=black:s={W}x{H}:r={FPS}[base];'
       f'[0:v]fps={FPS},scale={PHONE_W}:{PHONE_H}[clip];'
       f'[base][clip]overlay={PHONE_X}:{PHONE_Y}:shortest=1[v1];'
       f'[v1][1:v]overlay=0:0:shortest=1,format=yuv420p[v]',
       '-map', '[v]', '-t', str(length), '-c:v', 'libx264', '-pix_fmt', 'yuv420p', str(out))


def concat_with_fades(segments, durations, song, out):
    inputs = []
    for s in segments:
        inputs += ['-i', str(s)]
    inputs += ['-i', str(song)]
    parts = []
    last = '0:v'
    offset = 0.0
    for i in range(1, len(segments)):
        offset += durations[i - 1] - FADE
        tag = f'x{i}'
        parts.append(f'[{last}][{i}:v]xfade=transition=fade:duration={FADE}:offset={offset:.3f}[{tag}]')
        last = tag
    total = sum(durations) - FADE * (len(segments) - 1)
    a = len(segments)
    parts.append(f'[{a}:a]atrim=0:{total:.3f},afade=t=in:d=0.3,afade=t=out:st={total - 1.2:.3f}:d=1.2[a]')
    ff(*inputs, '-filter_complex', ';'.join(parts), '-map', f'[{last}]', '-map', '[a]',
       '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-c:a', 'aac', '-b:a', '160k',
       '-movflags', '+faststart', str(out))
    return total


def phone_shot(path, h):
    shot = Image.open(path).convert('RGB')
    w = round(h * shot.width / shot.height)
    shot = shot.resize((w, h), Image.LANCZOS)
    frame = Image.new('RGBA', (w + 24, h + 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(frame)
    d.rounded_rectangle([0, 0, w + 23, h + 23], radius=int(h * 0.06), fill=(12, 10, 24))
    mask = Image.new('L', (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w, h], radius=int(h * 0.05), fill=255)
    frame.paste(shot, (12, 12), mask)
    shadow = Image.new('RGBA', (frame.width + 80, frame.height + 80), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [40, 52, frame.width + 40, frame.height + 52], radius=int(h * 0.06), fill=(0, 0, 0, 110))
    shadow = shadow.filter(ImageFilter.GaussianBlur(24))
    shadow.alpha_composite(frame, (40, 40))
    return shadow


def gallery_row(canvas, shots, y, h, gap):
    """Centers the phones by their frame width (shadow padding excluded)."""
    phones = [phone_shot(s, h) for s in shots]
    pad = 40
    frames = [p.width - 2 * pad for p in phones]
    x = (canvas.width - (sum(frames) + gap * (len(phones) - 1))) // 2
    for i, p in enumerate(phones):
        lift = 0 if i in (1, 2) else 36
        canvas.alpha_composite(p, (x - pad, y - pad + lift))
        x += frames[i] + gap


def poster(shots, out):
    img = gradient(1080, 1350)
    d = ImageDraw.Draw(img)
    pill(d, 540, 70, 'NOW ON PUB.DEV', font(30, DEMI), (20, 18, 40), ACCENT)
    centered(d, 150, 'Flame Gallery', font(104, HEAVY), WHITE)
    centered(d, 290, 'Drop-in mini games for Flutter apps', font(42, DEMI), PRIMARY)
    gallery_row(img, shots, 430, 470, 18)
    names = ['Fruit Slice', 'Ruins Runner', 'Sweet Swap', 'Note Rush']
    centered(d, 1040, '  ·  '.join(names), font(34, DEMI), WHITE)
    mono = ImageFont.truetype(MONO, 30)
    code_box(d, 150, 1110, [('flutter pub add flame_gallery', ACCENT)], mono, 780)
    centered(d, 1245, 'vb10.github.io/flame_gallery', font(34, DEMI), MUTED)
    img.convert('RGB').save(out)


def og_image(shots, out):
    """Text column on the left (x < 640), three overlapping phones on the right."""
    img = gradient(1200, 630)
    d = ImageDraw.Draw(img)
    d.text((60, 150), 'Flame Gallery', font=font(76, HEAVY), fill=WHITE)
    d.text((62, 262), 'Drop-in mini games', font=font(38, DEMI), fill=PRIMARY)
    d.text((62, 310), 'for any Flutter app', font=font(38, DEMI), fill=PRIMARY)
    mono = ImageFont.truetype(MONO, 24)
    code_box(d, 60, 400, [('FlameGallery.show(context, ...)', ACCENT)], mono, 520)
    pad, step = 40, 150
    for i, s in enumerate(shots[:3]):
        p = phone_shot(s, 430)
        img.alpha_composite(p, (668 + i * step - pad, 88 - pad + (0 if i == 1 else 26)))
    img.convert('RGB').save(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--clips', type=Path, required=True)
    ap.add_argument('--shots', type=Path, required=True)
    ap.add_argument('--brand', type=Path, required=True)
    ap.add_argument('--song', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    shots = [args.shots / f'{n}.png' for n in ('fruit_slice', 'runner', 'sweet_swap', 'note_rush')]

    poster(shots, args.out / 'poster.png')
    og_image(shots, args.out / 'og.png')

    with tempfile.TemporaryDirectory() as tmp:
        tmp = Path(tmp)
        segments, durations = [], []

        def add_still(name, img, seconds):
            png = tmp / f'{name}.png'
            img.convert('RGB').save(png)
            seg = tmp / f'{name}.mp4'
            still_segment(png, seconds, seg)
            segments.append(seg)
            durations.append(seconds)

        add_still('intro', intro_card(), INTRO)
        for i, (name, src, start, length, title, caption) in enumerate(CLIPS, start=1):
            png = tmp / f'{name}_card.png'
            game_card(title, caption, i).save(png)
            seg = tmp / f'{name}.mp4'
            clip_segment(args.clips / src, start, length, png, seg)
            segments.append(seg)
            durations.append(length)
        add_still('brand', brand_card(args.brand), BRAND)
        add_still('outro', outro_card(), OUTRO)
        total = concat_with_fades(segments, durations, args.song, args.out / 'promo.mp4')
    print(f'promo.mp4 {total:.1f}s, poster.png, og.png -> {args.out}')


if __name__ == '__main__':
    main()
