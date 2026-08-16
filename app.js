// PutIT Web Simulator Engine
// 100% Client-Side LocalStorage + Web Speech API + Visual Anchor Pinning

const I18N = {
  th: {
    app_title: "PutIT",
    search_placeholder: "ค้นหาสิ่งของ (เช่น กุญแจ, พาสปอร์ต)",
    remember_hero: "+ ถ่ายรูปจำที่เก็บของใหม่",
    remember_sub: "AI ตรวจจับสิ่งของ & ปักหมุดตำแหน่งภาพให้อัตโนมัติ",
    saved_items: "ของที่บันทึกไว้",
    no_items: "ยังไม่มีสิ่งของในระบบ",
    no_items_sub: "แตะปุ่มถ่ายรูปด้านบนเพื่อเริ่มจำที่เก็บของชิ้นแรก",
    done: "เสร็จ",
    cancel: "ยกเลิก",
    back: "ย้อนกลับ",
    next: "ถัดไป",
    save: "บันทึก",
    step1_title: "1. ถ่ายรูป & ปักหมุด",
    step2_title: "2. ข้อมูลสิ่งของ",
    take_photo: "ถ่ายรูป / เลือกภาพ",
    skip_photo: "ข้ามรูปถ่าย (บันทึกข้อความอย่างเดียว)",
    item_name: "ชื่อสิ่งของ",
    room_label: "ห้อง",
    container_label: "ที่เก็บ / เฟอร์นิเจอร์",
    subspot_label: "จุดย่อย / มุมที่วาง",
    notes_label: "หมายเหตุเพิ่มเติม",
    found_it: "หาเจอแล้ว! (Found It)",
    memory_trail: "ประวัติการย้าย (Memory Trail)",
    smart_pack: "Smart Pack",
    smart_pack_sub: "เตรียมของ",
    language_title: "เลือกภาษา (15 ภาษา)",
    demo_data: "โหลดข้อมูลตัวอย่างสำหรับสาธิต",
    offline_status: "ออฟไลน์ 100% (On-Device LocalStorage)"
  },
  en: {
    app_title: "PutIT",
    search_placeholder: "Search items (e.g. key, passport)",
    remember_hero: "+ Remember New Item Spot",
    remember_sub: "AI Auto-Pin & Smart Spatial Recommendation",
    saved_items: "Saved Items",
    no_items: "No items saved yet",
    no_items_sub: "Tap '+ Remember New Item' to start tracking your first item",
    done: "Done",
    cancel: "Cancel",
    back: "Back",
    next: "Next",
    save: "Save",
    step1_title: "1. Photo & Anchor Pin",
    step2_title: "2. Item Details",
    take_photo: "Take Photo / Choose Image",
    skip_photo: "Skip photo (Text only)",
    item_name: "Item Name",
    room_label: "Room",
    container_label: "Storage / Furniture",
    subspot_label: "Specific Spot",
    notes_label: "Notes",
    found_it: "Found It!",
    memory_trail: "Location History (Memory Trail)",
    smart_pack: "Smart Pack",
    smart_pack_sub: "Pack Items",
    language_title: "Select Language (15)",
    demo_data: "Load Demo Sample Items",
    offline_status: "100% Offline (Local Client Storage)"
  },
  es: { app_title: "PutIT", search_placeholder: "Buscar objetos...", remember_hero: "+ Recordar nueva ubicación", done: "Listo", cancel: "Cancelar", save: "Guardar", found_it: "¡Encontrado!", smart_pack: "Smart Pack" },
  fr: { app_title: "PutIT", search_placeholder: "Rechercher des objets...", remember_hero: "+ Mémoriser un endroit", done: "OK", cancel: "Annuler", save: "Enregistrer", found_it: "Trouvé !", smart_pack: "Smart Pack" },
  de: { app_title: "PutIT", search_placeholder: "Gegenstände suchen...", remember_hero: "+ Neuen Ablageort merken", done: "Fertig", cancel: "Abbrechen", save: "Speichern", found_it: "Gefunden!", smart_pack: "Smart Pack" },
  "zh-Hans": { app_title: "PutIT", search_placeholder: "搜索物品...", remember_hero: "+ 拍照记录存放位置", done: "完成", cancel: "取消", save: "保存", found_it: "找到了！", smart_pack: "智能打包" },
  ja: { app_title: "PutIT", search_placeholder: "アイテムを検索...", remember_hero: "+ 保管場所を撮影・記録", done: "完了", cancel: "キャンセル", save: "保存", found_it: "見つかりました！", smart_pack: "スマートパック" },
  ko: { app_title: "PutIT", search_placeholder: "물건 검색...", remember_hero: "+ 보관 위치 기억하기", done: "완료", cancel: "취소", save: "저장", found_it: "찾았습니다!", smart_pack: "스마트 팩" },
  "pt-BR": { app_title: "PutIT", search_placeholder: "Buscar itens...", remember_hero: "+ Lembrar novo local", done: "OK", cancel: "Cancelar", save: "Salvar", found_it: "Encontrei!", smart_pack: "Smart Pack" },
  it: { app_title: "PutIT", search_placeholder: "Cerca oggetti...", remember_hero: "+ Ricorda nuova posizione", done: "Fine", cancel: "Annulla", save: "Salva", found_it: "Trovato!", smart_pack: "Smart Pack" },
  ru: { app_title: "PutIT", search_placeholder: "Поиск вещей...", remember_hero: "+ Запомнить место", done: "Готово", cancel: "Отмена", save: "Сохранить", found_it: "Найдено!", smart_pack: "Smart Pack" },
  ar: { app_title: "PutIT", search_placeholder: "البحث عن الأشياء...", remember_hero: "+ تذكر مكان جديد", done: "تم", cancel: "إلغاء", save: "حفظ", found_it: "وجدتُه!", smart_pack: "Smart Pack" },
  hi: { app_title: "PutIT", search_placeholder: "वस्तुएं खोजें...", remember_hero: "+ नया स्थान याद रखें", done: "पूर्ण", cancel: "रद्द करें", save: "सहेजें", found_it: "मिल गया!", smart_pack: "Smart Pack" },
  tr: { app_title: "PutIT", search_placeholder: "Eşyaları ara...", remember_hero: "+ Yeni Konum Hatırla", done: "Tamam", cancel: "İptal", save: "Kaydet", found_it: "Buldum!", smart_pack: "Smart Pack" },
  vi: { app_title: "PutIT", search_placeholder: "Tìm kiếm đồ đạc...", remember_hero: "+ Lưu vị trí đồ vật mới", done: "Xong", cancel: "Hủy", save: "Lưu", found_it: "Đã tìm thấy!", smart_pack: "Smart Pack" }
};

const LANGUAGES = [
  { code: "th", name: "🇹🇭 ภาษาไทย (Thai)" },
  { code: "en", name: "🇬🇧 English (Default)" },
  { code: "es", name: "🇪🇸 Español (Spanish)" },
  { code: "fr", name: "🇫🇷 Français (French)" },
  { code: "de", name: "🇩🇪 Deutsch (German)" },
  { code: "zh-Hans", name: "🇨🇳 简体中文 (Mandarin)" },
  { code: "ja", name: "🇯🇵 日本語 (Japanese)" },
  { code: "ko", name: "🇰🇷 한국어 (Korean)" },
  { code: "pt-BR", name: "🇧🇷 Português (Brasil)" },
  { code: "it", name: "🇮🇹 Italiano (Italian)" },
  { code: "ru", name: "🇷🇺 Русский (Russian)" },
  { code: "ar", name: "🇸🇦 العربية (Arabic)" },
  { code: "hi", name: "🇮🇳 हिन्दी (Hindi)" },
  { code: "tr", name: "🇹🇷 Türkçe (Turkish)" },
  { code: "vi", name: "🇻🇳 Tiếng Việt (Vietnamese)" }
];

const PACK_TEMPLATES = [
  {
    id: "travel",
    title: "เดินทาง & ท่องเที่ยว (Travel)",
    items: ["Passport", "Wallet", "Charger", "Medicine", "Glasses"]
  },
  {
    id: "work",
    title: "ไปทำงาน / ออกข้างนอก (Work)",
    items: ["Laptop", "Mouse", "Keycard", "Headphones", "Charger"]
  },
  {
    id: "daily",
    title: "ของจำเป็นประจำวัน (Daily)",
    items: ["Key", "Car Key", "Wallet", "Glasses", "Umbrella"]
  }
];

// App State
let currentLang = localStorage.getItem("putit_lang") || "th";
let items = JSON.parse(localStorage.getItem("putit_items") || "[]");
let selectedCategory = "all";
let currentStep = 1;
let currentImageUri = null;
let currentPin = { x: 0.5, y: 0.5 };
let currentSelectedItem = null;
let currentPackTemplateIndex = 0;
let packedMap = JSON.parse(localStorage.getItem("putit_packed") || "{}");

// Elements
const itemsListEl = document.getElementById("itemsList");
const emptyStateEl = document.getElementById("emptyState");
const searchInputEl = document.getElementById("searchInput");
const micBtnEl = document.getElementById("micBtn");
const voiceStatusEl = document.getElementById("voiceStatus");

// Translation Helper
function t(key) {
  const dict = I18N[currentLang] || I18N["en"];
  return dict[key] || I18N["en"][key] || key;
}

function updateUILabels() {
  document.querySelectorAll("[data-i18n]").forEach(el => {
    const key = el.getAttribute("data-i18n");
    if (el.tagName === "INPUT") {
      el.placeholder = t(key);
    } else {
      el.textContent = t(key);
    }
  });
  document.getElementById("currentLangDisplay").textContent = LANGUAGES.find(l => l.code === currentLang)?.name || "🇹🇭 ภาษาไทย";
}

// Render Items
function renderItems() {
  const query = searchInputEl.value.trim().toLowerCase();
  const filtered = items.filter(item => {
    const matchCat = selectedCategory === "all" || item.category.toLowerCase().includes(selectedCategory.toLowerCase());
    const matchQuery = !query || 
      item.name.toLowerCase().includes(query) || 
      item.room.toLowerCase().includes(query) || 
      item.container.toLowerCase().includes(query) ||
      (item.tags && item.tags.some(tg => tg.toLowerCase().includes(query)));
    return matchCat && matchQuery;
  });

  document.getElementById("itemsCount").textContent = `(${filtered.length})`;

  if (filtered.length === 0) {
    itemsListEl.style.display = "none";
    emptyStateEl.style.display = "flex";
    return;
  }

  itemsListEl.style.display = "flex";
  emptyStateEl.style.display = "none";
  itemsListEl.innerHTML = "";

  filtered.forEach(item => {
    const card = document.createElement("div");
    card.className = "item-card";
    card.onclick = () => openItemDetail(item);

    const thumbHtml = item.imageUri 
      ? `<img src="${item.imageUri}" class="item-thumb-img" alt="${item.name}" />`
      : `<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;color:#666;font-size:24px;">📦</div>`;

    card.innerHTML = `
      <div class="item-thumb-box">
        ${thumbHtml}
        ${item.pin ? `<div class="pin-badge">PIN</div>` : ''}
      </div>
      <div class="item-info">
        <div class="item-name-row">
          <span class="item-name">${item.name}</span>
          <span class="item-category-tag">${item.category}</span>
        </div>
        <div class="item-location-text">
          <span>📍 ${item.room} › ${item.container}${item.subSpot ? ` › ${item.subSpot}` : ''}</span>
        </div>
        <div class="item-time-text">บันทึกเมื่อ: ${new Date(item.createdAt).toLocaleDateString(currentLang === 'th' ? 'th-TH' : 'en-US')}</div>
      </div>
    `;
    itemsListEl.appendChild(card);
  });
}

// Category filter
document.querySelectorAll(".category-pill").forEach(pill => {
  pill.addEventListener("click", () => {
    document.querySelectorAll(".category-pill").forEach(p => p.classList.remove("active"));
    pill.classList.add("active");
    selectedCategory = pill.getAttribute("data-cat");
    renderItems();
  });
});

// Search input
searchInputEl.addEventListener("input", renderItems);

// Voice Search (Web Speech API)
let recognition = null;
if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
  const SpeechRec = window.SpeechRecognition || window.webkitSpeechRecognition;
  recognition = new SpeechRec();
  recognition.lang = currentLang === 'th' ? 'th-TH' : 'en-US';
  recognition.continuous = false;
  recognition.interimResults = false;

  recognition.onstart = () => {
    micBtnEl.classList.add("recording");
    voiceStatusEl.style.display = "flex";
  };

  recognition.onresult = (event) => {
    const transcript = event.results[0][0].transcript;
    searchInputEl.value = transcript;
    renderItems();
  };

  recognition.onend = () => {
    micBtnEl.classList.remove("recording");
    voiceStatusEl.style.display = "none";
  };
}

micBtnEl.addEventListener("click", () => {
  if (!recognition) {
    alert("เบราว์เซอร์ของคุณยังไม่รองรับ Web Speech Recognition");
    return;
  }
  try {
    recognition.start();
  } catch (e) {
    recognition.stop();
  }
});

// Modal Helpers
function openModal(id) {
  document.getElementById(id).classList.add("active");
}

function closeModal(id) {
  document.getElementById(id).classList.remove("active");
}

// --- Remember Flow ---
function startRememberFlow() {
  currentStep = 1;
  currentImageUri = null;
  currentPin = { x: 0.5, y: 0.5 };
  document.getElementById("step1Container").style.display = "flex";
  document.getElementById("step2Container").style.display = "none";
  document.getElementById("rememberNextBtn").style.display = "block";
  document.getElementById("rememberSaveBtn").style.display = "none";
  document.getElementById("canvasSection").style.display = "none";
  document.getElementById("photoButtonsSection").style.display = "flex";
  document.getElementById("itemNameInput").value = "";
  document.getElementById("roomInput").value = "";
  document.getElementById("containerInput").value = "";
  document.getElementById("subSpotInput").value = "";
  document.getElementById("notesInput").value = "";
  openModal("rememberModal");
}

function handleImageUpload(event) {
  const file = event.target.files[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = (e) => {
    currentImageUri = e.target.result;
    document.getElementById("pinCanvasImg").src = currentImageUri;
    document.getElementById("canvasSection").style.display = "block";
    document.getElementById("photoButtonsSection").style.display = "none";

    // Simulate On-Device AI Saliency & Classification
    runAISimulation(file.name);
  };
  reader.readAsDataURL(file);
}

function runAISimulation(fileName) {
  const aiStatus = document.getElementById("aiStatusText");
  const chipsBox = document.getElementById("aiChipsRow");
  aiStatus.textContent = "⚡ Apple Vision AI วิเคราะห์ภาพ & Auto-Pin...";
  chipsBox.innerHTML = "";

  setTimeout(() => {
    aiStatus.textContent = "✨ AI ตรวจพบวัตถุ & ปักหมุดให้อัตโนมัติ (แตะบนภาพเพื่อย้ายได้)";
    currentPin = { x: 0.5, y: 0.45 };
    updatePinPosition();

    // Predictions
    const predictions = [
      { name: "พาสปอร์ต (Passport)", cat: "Documents", room: "ห้องนอนใหญ่", box: "ตู้เซฟ" },
      { name: "กุญแจรถ (Car Key)", cat: "Keys & Access", room: "หน้าบ้าน", box: "ที่แขวนผนัง" },
      { name: "เมาส์ (Mouse)", cat: "Electronics", room: "ห้องทำงาน", box: "โต๊ะทำงาน" },
      { name: "ยาแก้แพ้ (Medicine)", cat: "Medicines", room: "ห้องครัว", box: "ตู้ยา" }
    ];

    predictions.forEach((pred, idx) => {
      const chip = document.createElement("button");
      chip.className = `ai-chip ${idx === 0 ? 'active' : ''}`;
      chip.textContent = pred.name;
      chip.onclick = () => {
        document.querySelectorAll(".ai-chip").forEach(c => c.classList.remove("active"));
        chip.classList.add("active");
        document.getElementById("itemNameInput").value = pred.name.split(" (")[0];
        document.getElementById("roomInput").value = pred.room;
        document.getElementById("containerInput").value = pred.box;
      };
      chipsBox.appendChild(chip);
    });

    // Auto-fill top prediction
    document.getElementById("itemNameInput").value = predictions[0].name.split(" (")[0];
    document.getElementById("roomInput").value = predictions[0].room;
    document.getElementById("containerInput").value = predictions[0].box;
  }, 400);
}

// Canvas Pin Drag / Tap
const canvasContainer = document.getElementById("canvasContainer");
const pulsingPinEl = document.getElementById("pulsingPin");

canvasContainer.addEventListener("pointerdown", (e) => {
  const rect = canvasContainer.getBoundingClientRect();
  const x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
  const y = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height));
  currentPin = { x, y };
  updatePinPosition();
});

function updatePinPosition() {
  pulsingPinEl.style.left = `${currentPin.x * 100}%`;
  pulsingPinEl.style.top = `${currentPin.y * 100}%`;
}

function goToRememberStep2() {
  currentStep = 2;
  document.getElementById("step1Container").style.display = "none";
  document.getElementById("step2Container").style.display = "flex";
  document.getElementById("rememberNextBtn").style.display = "none";
  document.getElementById("rememberSaveBtn").style.display = "block";
}

function saveRememberItem() {
  const name = document.getElementById("itemNameInput").value.trim();
  const room = document.getElementById("roomInput").value.trim();
  const container = document.getElementById("containerInput").value.trim();
  const subSpot = document.getElementById("subSpotInput").value.trim();
  const note = document.getElementById("notesInput").value.trim();

  if (!name || !room) {
    alert("กรุณากรอกชื่อสิ่งของและห้อง");
    return;
  }

  const newItem = {
    id: Date.now().toString(),
    name,
    category: "General",
    room,
    container: container || "โต๊ะ / ตู้",
    subSpot,
    note,
    imageUri: currentImageUri,
    pin: currentPin,
    createdAt: new Date().toISOString(),
    trail: [
      { room, container, subSpot, date: new Date().toISOString(), note: "บันทึกครั้งแรก" }
    ]
  };

  items.unshift(newItem);
  localStorage.setItem("putit_items", JSON.stringify(items));
  closeModal("rememberModal");
  renderItems();
}

// Chip Click Handlers
function setupChipButtons(containerId, inputId) {
  document.querySelectorAll(`#${containerId} .chip-btn`).forEach(btn => {
    btn.onclick = () => {
      document.getElementById(inputId).value = btn.textContent;
    };
  });
}
setupChipButtons("roomChips", "roomInput");
setupChipButtons("containerChips", "containerInput");
setupChipButtons("subSpotChips", "subSpotInput");

// --- Item Detail ---
function openItemDetail(item) {
  currentSelectedItem = item;
  document.getElementById("detailTitle").textContent = item.name;
  document.getElementById("detailRoom").textContent = item.room;
  document.getElementById("detailContainer").textContent = item.container;
  document.getElementById("detailSubSpot").textContent = item.subSpot || "-";
  document.getElementById("detailNotes").textContent = item.note || "ไม่มีหมายเหตุ";

  const pinContainer = document.getElementById("detailPinContainer");
  if (item.imageUri) {
    document.getElementById("detailCanvasImg").src = item.imageUri;
    pinContainer.style.display = "flex";
    if (item.pin) {
      document.getElementById("detailPulsingPin").style.left = `${item.pin.x * 100}%`;
      document.getElementById("detailPulsingPin").style.top = `${item.pin.y * 100}%`;
    }
  } else {
    pinContainer.style.display = "none";
  }

  // Render Trail
  const trailBox = document.getElementById("detailTrailBox");
  trailBox.innerHTML = "";
  (item.trail || []).forEach(tr => {
    const row = document.createElement("div");
    row.style.fontSize = "13px";
    row.style.padding = "6px 0";
    row.style.borderBottom = "1px solid var(--border-color)";
    row.innerHTML = `📍 <strong>${tr.room} › ${tr.container}</strong> (${new Date(tr.date).toLocaleDateString()})`;
    trailBox.appendChild(row);
  });

  openModal("detailModal");
}

function deleteCurrentItem() {
  if (!confirm("คุณต้องการลบสิ่งของนี้ใช่หรือไม่?")) return;
  items = items.filter(i => i.id !== currentSelectedItem.id);
  localStorage.setItem("putit_items", JSON.stringify(items));
  closeModal("detailModal");
  renderItems();
}

function markAsFound() {
  alert("🎉 เยี่ยมมาก! คุณได้ตรวจสอบตำแหน่งสิ่งของเรียบร้อยแล้ว");
  closeModal("detailModal");
}

// --- Smart Pack ---
function openSmartPack() {
  renderSmartPack();
  openModal("smartPackModal");
}

function renderSmartPack() {
  const tpl = PACK_TEMPLATES[currentPackTemplateIndex];
  const listEl = document.getElementById("packItemsList");
  listEl.innerHTML = "";

  let packedCount = 0;
  tpl.items.forEach(itemName => {
    const key = `${tpl.id}_${itemName}`;
    const isDone = packedMap[key] === true;
    if (isDone) packedCount++;

    // Find in inventory
    const matched = items.find(i => i.name.toLowerCase().includes(itemName.toLowerCase()));

    const itemRow = document.createElement("div");
    itemRow.className = `checklist-item ${isDone ? 'done' : ''}`;
    itemRow.onclick = () => {
      packedMap[key] = !isDone;
      localStorage.setItem("putit_packed", JSON.stringify(packedMap));
      renderSmartPack();
    };

    itemRow.innerHTML = `
      <div class="checkbox-circle">${isDone ? '✓' : ''}</div>
      <div style="flex:1;">
        <div class="check-name" style="font-weight:700;">${itemName}</div>
        <div style="font-size:12px;color:var(--text-secondary);">
          ${matched ? `📍 ${matched.room} › ${matched.container}` : 'ยังไม่มีรูปหรือจุดปักในระบบ'}
        </div>
      </div>
      ${matched && matched.imageUri ? `<img src="${matched.imageUri}" style="width:36px;height:36px;border-radius:8px;object-fit:cover;" />` : ''}
    `;
    listEl.appendChild(itemRow);
  });

  const pct = Math.round((packedCount / tpl.items.length) * 100);
  document.getElementById("packProgressText").textContent = `เตรียมของแล้ว ${packedCount} จาก ${tpl.items.length} ชิ้น (${pct}%)`;
  document.getElementById("packProgressBar").style.width = `${pct}%`;
}

function switchPackTemplate(idx) {
  currentPackTemplateIndex = idx;
  document.querySelectorAll("#packScenarioScroll .category-pill").forEach((p, i) => {
    p.classList.toggle("active", i === idx);
  });
  renderSmartPack();
}

// --- Settings & Language ---
function openSettings() {
  openModal("settingsModal");
}

function openLanguageSheet() {
  const list = document.getElementById("languagesList");
  list.innerHTML = "";
  LANGUAGES.forEach(lang => {
    const btn = document.createElement("button");
    btn.className = "checklist-item";
    btn.style.width = "100%";
    btn.innerHTML = `
      <span style="font-weight:600;">${lang.name}</span>
      <span style="margin-left:auto;color:var(--primary);">${currentLang === lang.code ? '✓' : ''}</span>
    `;
    btn.onclick = () => {
      currentLang = lang.code;
      localStorage.setItem("putit_lang", currentLang);
      updateUILabels();
      closeModal("languageModal");
      renderItems();
    };
    list.appendChild(btn);
  });
  openModal("languageModal");
}

function resetDemoData() {
  items = [
    {
      id: "demo-1",
      name: "หนังสือเดินทาง (Passport)",
      category: "Documents",
      room: "ห้องนอนใหญ่",
      container: "ตู้เซฟนิรภัย",
      subSpot: "ชั้นบนสุด",
      note: "สำหรับทริปต่างประเทศ",
      imageUri: "https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&auto=format&fit=crop&q=80",
      pin: { x: 0.5, y: 0.5 },
      createdAt: new Date().toISOString(),
      trail: [{ room: "ห้องนอนใหญ่", container: "ตู้เซฟนิรภัย", subSpot: "ชั้นบนสุด", date: new Date().toISOString(), note: "บันทึกข้อมูลตัวอย่าง" }]
    },
    {
      id: "demo-2",
      name: "กุญแจสำรอง (Spare Key)",
      category: "Keys & Access",
      room: "หน้าบ้าน",
      container: "ตู้รองเท้า",
      subSpot: "ลิ้นชักซ้าย",
      note: "กุญแจรถยนต์สำรอง",
      imageUri: "https://images.unsplash.com/photo-1582139329536-e7284fece509?w=600&auto=format&fit=crop&q=80",
      pin: { x: 0.45, y: 0.55 },
      createdAt: new Date().toISOString(),
      trail: [{ room: "หน้าบ้าน", container: "ตู้รองเท้า", subSpot: "ลิ้นชักซ้าย", date: new Date().toISOString(), note: "บันทึกข้อมูลตัวอย่าง" }]
    }
  ];
  localStorage.setItem("putit_items", JSON.stringify(items));
  renderItems();
  alert("โหลดข้อมูลตัวอย่างสำหรับทดสอบเรียบร้อยแล้ว!");
  closeModal("settingsModal");
}

// Initial Boot
updateUILabels();
renderItems();
