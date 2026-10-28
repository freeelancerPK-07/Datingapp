import 'package:flutter/material.dart';

class LinkUpTheme {
  static const Color primaryTeal = Color(0xFF007A78);
  static const Color deepTeal = Color(0xFF005E5D);
  static const Color mintAccent = Color(0xFF00A896);
  static const Color darkSlate = Color(0xFF0F2B32);

  // Unified brand colors replacing old pinks across the app
  static const Color activePink = Color(0xFF007A78);
  static const Color mediumPink = Color(0xFF00A896);
  static const Color palePink = Color(0xFFE5F7F4);
  static const Color brandDark = Color(0xFF0F2B32);
  static const Color textMuted = Color(0xFF4A6B74);
  static const Color inputBg = Color(0xFFF7FAFC);
  static const Color inputBorder = Color(0xFFE2EAEF);
  static const Color dividerColor = Color(0xFFE2EAEF);
  static const Color socialBg = Color(0xFFF7F8FA);
  static const Color socialBorder = Color(0xFFE2EAEF);
  static const Color blobYellow = Color(0xFFFFD43B);
  static const Color blobCyan = Color(0xFF2DD4BF);
  static const Color blobBlue = Color(0xFF007A78);
  static const Color blobPurple = Color(0xFF005E5D);

  // App-Wide Unified Hero Gradient (Teal to Mint)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF0B2B30), // Obsidian Dark Teal
      Color(0xFF005E5D), // Rich Teal
      Color(0xFF007A78), // LinkUp Teal
      Color(0xFF00A896), // Radiant Mint
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // App-Wide Unified Button & CTA Gradient
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      Color(0xFF005E5D),
      Color(0xFF00A896),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // App-Wide Avatar Ring Gradient
  static const LinearGradient ringGradient = LinearGradient(
    colors: [
      Color(0xFF007A78),
      Color(0xFF00C49F),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class LinkUpVectors {
  static const String topBlobSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 450 400">
  <path d="M 211 104 L 209 106 L 209 114 L 219 142 L 226 156 L 232 164 L 236 166 L 244 165 L 248 160 L 248 152 L 243 142 L 221 109 L 216 104 Z M 230 90 L 234 95 L 260 110 L 273 113 L 279 111 L 282 107 L 281 98 L 273 93 L 238 85 L 233 85 Z M 306 0 L 0 0 L 0 308 L 21 304 L 48 292 L 75 272 L 93 252 L 105 233 L 115 211 L 123 186 L 127 163 L 151 130 L 170 89 L 192 78 L 235 64 L 259 52 L 286 31 L 299 15 Z" fill="#FDB8D8" />
  <path d="M 210 106 L 209 110 L 211 118 L 225 153 L 235 165 L 244 164 L 247 160 L 247 152 L 242 142 L 220 109 L 216 105 Z M 231 88 L 231 91 L 234 94 L 260 109 L 274 112 L 279 110 L 282 106 L 280 98 L 271 93 L 238 86 L 233 86 Z M 0 227 L 18 225 L 54 214 L 80 201 L 109 180 L 139 147 L 154 123 L 178 73 L 198 45 L 229 11 L 235 0 L 0 0 Z" fill="#FD2D88" />
</svg>
''';

  static const String bottomBlobSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 461 472">
  <path d="M 275 175 L 275 182 L 281 189 L 316 204 L 321 204 L 323 202 L 321 195 L 288 171 L 279 171 Z M 460 143 L 444 146 L 421 156 L 403 169 L 381 193 L 370 210 L 358 234 L 336 298 L 325 318 L 310 319 L 248 310 L 215 309 L 188 312 L 168 317 L 136 331 L 103 354 L 83 374 L 70 390 L 49 427 L 39 455 L 36 471 L 460 471 Z M 376 141 L 370 140 L 367 144 L 361 174 L 366 176 L 370 171 L 377 149 Z M 309 119 L 303 125 L 305 138 L 332 185 L 338 189 L 342 187 L 343 183 L 331 145 L 320 123 L 315 119 Z" fill="#FDB8D8" />
  <path d="M 460 251 L 440 255 L 424 262 L 403 276 L 373 302 L 346 316 L 330 319 L 299 319 L 249 311 L 212 310 L 171 317 L 154 323 L 134 333 L 104 354 L 83 375 L 71 390 L 49 429 L 42 448 L 37 471 L 213 471 L 222 452 L 244 423 L 264 405 L 291 389 L 307 383 L 331 378 L 391 377 L 419 372 L 439 364 L 460 349 Z M 276 175 L 276 182 L 281 188 L 313 202 L 322 202 L 322 198 L 294 175 L 288 172 L 279 172 Z M 374 141 L 369 142 L 362 174 L 367 175 L 376 149 L 376 143 Z M 309 120 L 304 125 L 304 132 L 308 143 L 333 185 L 339 188 L 342 185 L 341 178 L 327 138 L 320 124 L 316 120 Z" fill="#FD2D88" />
</svg>
''';

  static const String logoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 622 238">
  <path d="M 51 146 L 48 146 L 39 152 L 30 161 L 30 165 L 34 168 L 37 167 L 50 154 L 52 151 Z M 49 121 L 47 119 L 38 119 L 17 122 L 5 125 L 2 128 L 3 136 L 8 138 L 46 128 L 49 125 Z M 15 82 L 14 86 L 15 88 L 22 93 L 46 102 L 50 102 L 52 101 L 53 99 L 52 95 L 25 80 L 19 79 Z" fill="#FFBA08" />
  <path d="M 117 32 L 114 36 L 114 44 L 119 50 L 127 50 L 135 61 L 145 69 L 152 73 L 156 73 L 160 69 L 169 49 L 171 37 L 172 36 L 171 28 L 167 23 L 165 22 L 157 22 L 155 23 L 151 28 L 149 35 L 149 40 L 146 43 L 137 34 L 129 30 L 121 30 Z" fill="#FD5A78" />
  <path d="M 158 88 L 150 91 L 146 99 L 146 132 L 148 149 L 153 169 L 159 177 L 168 178 L 173 176 L 178 168 L 179 163 L 178 134 L 175 113 L 170 94 L 166 90 Z M 196 75 L 192 80 L 190 86 L 188 110 L 189 152 L 191 166 L 195 176 L 203 182 L 210 182 L 215 180 L 218 177 L 221 171 L 224 154 L 230 135 L 237 123 L 245 116 L 247 116 L 252 121 L 254 128 L 253 165 L 256 173 L 259 176 L 265 178 L 270 178 L 277 175 L 280 172 L 284 163 L 287 142 L 286 109 L 282 94 L 277 85 L 268 77 L 261 74 L 254 73 L 244 75 L 236 79 L 221 94 L 219 92 L 219 86 L 217 79 L 214 75 L 208 72 L 202 72 Z M 97 63 L 88 69 L 84 76 L 81 86 L 77 117 L 77 144 L 82 171 L 86 179 L 90 184 L 97 188 L 110 189 L 122 185 L 134 175 L 140 164 L 141 154 L 138 147 L 135 144 L 130 142 L 118 143 L 116 141 L 117 111 L 119 98 L 119 75 L 115 67 L 111 64 Z M 318 38 L 314 40 L 309 45 L 305 54 L 303 65 L 297 126 L 297 166 L 301 176 L 307 180 L 316 180 L 320 178 L 323 175 L 326 168 L 328 154 L 328 142 L 330 140 L 345 163 L 356 176 L 364 180 L 373 180 L 377 178 L 383 170 L 384 165 L 383 158 L 374 143 L 353 117 L 371 102 L 382 91 L 386 82 L 385 74 L 380 68 L 367 67 L 353 76 L 335 93 L 333 91 L 333 86 L 337 59 L 336 48 L 334 43 L 331 40 L 327 38 Z" fill="#18181B" fill-rule="evenodd" />
  <path d="M 618 77 L 616 75 L 610 75 L 585 81 L 582 84 L 583 89 L 594 89 L 615 85 L 617 84 L 618 82 Z M 603 36 L 601 34 L 595 34 L 587 39 L 565 59 L 566 65 L 570 66 L 576 63 L 600 46 L 603 43 Z M 560 5 L 555 5 L 553 6 L 550 12 L 540 41 L 540 46 L 542 48 L 545 48 L 548 46 L 561 19 L 563 13 L 563 8 Z" fill="#18181B" />
  <path d="M 569 112 L 554 107 L 546 107 L 536 109 L 532 104 L 528 102 L 520 102 L 513 108 L 503 136 L 490 192 L 488 211 L 489 222 L 491 227 L 495 231 L 500 233 L 505 233 L 510 231 L 516 224 L 521 204 L 523 187 L 525 185 L 529 188 L 539 192 L 554 192 L 569 186 L 577 179 L 582 172 L 588 156 L 588 139 L 582 124 Z M 542 133 L 548 133 L 552 135 L 557 140 L 559 148 L 556 156 L 550 162 L 546 164 L 539 164 L 535 162 L 529 155 L 529 146 L 532 140 L 537 135 Z M 428 47 L 421 50 L 416 55 L 404 78 L 399 93 L 395 112 L 395 123 L 394 124 L 395 142 L 398 153 L 402 162 L 407 170 L 413 176 L 428 184 L 446 185 L 454 183 L 468 175 L 476 167 L 485 154 L 493 138 L 499 121 L 507 86 L 507 74 L 504 68 L 501 65 L 495 62 L 485 63 L 477 70 L 474 77 L 467 108 L 461 126 L 454 139 L 446 147 L 436 148 L 430 143 L 428 139 L 427 121 L 430 107 L 435 92 L 445 69 L 446 60 L 445 56 L 441 50 L 435 47 Z" fill="#FD2D88" fill-rule="evenodd" />
</svg>
''';

  static const String googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path fill="#4285F4" d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.82-2.4 3.68v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.17z"/>
  <path fill="#34A853" d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.36 24 12 24z"/>
  <path fill="#FBBC05" d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 9.99 0 12s.45 3.82 1.25 5.42l4.03-3.15z"/>
  <path fill="#EA4335" d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.36 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z"/>
</svg>
''';
}
