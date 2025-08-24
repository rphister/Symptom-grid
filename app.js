const BodyAreas = ["Hands","Elbows","Shoulders","Knees","Ankles"];
const TimeSlots = ["Morning","Midday","Evening","Night"];

function fmtDateISO(d){
  const tzoff = d.getTimezoneOffset();
  const local = new Date(d.getTime()-tzoff*60000);
  return local.toISOString().slice(0,10);
}

function emptyDay(dateISO){
  const entries = {};
  BodyAreas.forEach(area => {
    entries[area] = {};
    TimeSlots.forEach(slot => {
      entries[area][slot] = { pain:0, numbness:false, stiffness:"None", notes:"" };
    });
  });
  return { dateISO, entries };
}

function loadAll(){
  try{
    return JSON.parse(localStorage.getItem("symptom_logs")||"{}");
  }catch(e){ return {}; }
}
function saveAll(data){
  localStorage.setItem("symptom_logs", JSON.stringify(data));
}

function getDay(dateISO){
  const store = loadAll();
  if(!store[dateISO]){
    store[dateISO] = emptyDay(dateISO);
    saveAll(store);
  }
  return store[dateISO];
}
function setCell(dateISO, area, slot, cell){
  const store = loadAll();
  if(!store[dateISO]) store[dateISO]=emptyDay(dateISO);
  store[dateISO].entries[area][slot] = cell;
  saveAll(store);
}

function exportCSV(dateISO){
  const day = getDay(dateISO);
  const lines = ["Area,Time,Pain,Numbness,Stiffness,Notes,Date"];
  BodyAreas.forEach(area => {
    TimeSlots.forEach(slot => {
      const c = day.entries[area][slot];
      const notes = csvEscape(c.notes||"");
      lines.push([area,slot,c.pain, c.numbness ? "Yes":"No", c.stiffness, notes, dateISO].join(","));
    });
  });
  const blob = new Blob([lines.join("\n")], {type:"text/csv"});
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = `SymptomGrid_${dateISO}.csv`;
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

function csvEscape(s){
  if(/[",\n]/.test(s)){
    return \"\${s.replace(/\\/g,'\\\\').replace(/"/g,'\"')}\\";
  }
  return s;
}

const rowsEl = document.getElementById("rows");
const dateEl = document.getElementById("date");
const exportBtn = document.getElementById("exportCsv");
const resetBtn = document.getElementById("resetDay");

const sheet = document.getElementById("editorSheet");
const backdrop = document.getElementById("sheetBackdrop");
const closeSheetBtn = document.getElementById("closeSheet");
const cancelEditBtn = document.getElementById("cancelEdit");
const editorForm = document.getElementById("editorForm");
const painInput = document.getElementById("pain");
const painVal = document.getElementById("painVal");
const numbnessInput = document.getElementById("numbness");
const stiffnessSelect = document.getElementById("stiffness");
const notesInput = document.getElementById("notes");
const sheetTitle = document.getElementById("sheetTitle");

let currentDateISO = fmtDateISO(new Date());
let editing = null; // { area, slot }

function render(){
  const day = getDay(currentDateISO);
  rowsEl.innerHTML = "";
  BodyAreas.forEach(area => {
    const row = document.createElement("div");
    row.className = "row";
    const fc = document.createElement("div");
    fc.className="first-col";
    fc.textContent = area;
    row.appendChild(fc);
    TimeSlots.forEach(slot => {
      const cellData = day.entries[area][slot];
      const cell = document.createElement("div");
      cell.className = "cell";
      const line1 = document.createElement("div");
      line1.className="line1";
      const pain = document.createElement("div");
      pain.textContent = "Pain: " + (cellData.pain ?? 0);
      const numb = document.createElement("div");
      if(cellData.numbness) numb.textContent = "⚡"; else numb.textContent = "";
      line1.appendChild(pain);
      line1.appendChild(numb);
      const stiff = document.createElement("div");
      stiff.className="badge";
      stiff.textContent = cellData.stiffness || "None";
      const note = document.createElement("div");
      note.className="note";
      note.textContent = cellData.notes || "";
      cell.appendChild(line1);
      cell.appendChild(stiff);
      cell.appendChild(note);
      cell.addEventListener("click", () => openEditor(area, slot, cellData));
      row.appendChild(cell);
    });
    rowsEl.appendChild(row);
  });
}

function openEditor(area, slot, data){
  editing = { area, slot };
  sheetTitle.textContent = `${area} – ${slot}`;
  painInput.value = data.pain ?? 0;
  painVal.textContent = painInput.value;
  numbnessInput.checked = !!data.numbness;
  stiffnessSelect.value = data.stiffness || "None";
  notesInput.value = data.notes || "";
  backdrop.classList.remove("hidden");
  sheet.classList.remove("hidden");
}

function closeEditor(){
  editing = null;
  sheet.classList.add("hidden");
  backdrop.classList.add("hidden");
}

painInput.addEventListener("input", () => painVal.textContent = painInput.value);
closeSheetBtn.addEventListener("click", closeEditor);
cancelEditBtn.addEventListener("click", closeEditor);
backdrop.addEventListener("click", closeEditor);

editorForm.addEventListener("submit", (e) => {
  e.preventDefault();
  if(!editing) return;
  const cell = {
    pain: parseInt(painInput.value,10) || 0,
    numbness: !!numbnessInput.checked,
    stiffness: stiffnessSelect.value,
    notes: notesInput.value.trim()
  };
  setCell(currentDateISO, editing.area, editing.slot, cell);
  closeEditor();
  render();
});

dateEl.value = currentDateISO;
dateEl.addEventListener("change", () => {
  currentDateISO = dateEl.value || fmtDateISO(new Date());
  // ensure day exists:
  getDay(currentDateISO);
  render();
});

exportBtn.addEventListener("click", () => exportCSV(currentDateISO));
resetBtn.addEventListener("click", () => {
  if(confirm("Clear all entries for this day?")){
    const store = loadAll();
    store[currentDateISO] = emptyDay(currentDateISO);
    saveAll(store);
    render();
  }
});

// Register service worker (optional; requires https hosting)
if("serviceWorker" in navigator){
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("./sw.js").catch(()=>{});
  });
}

render();
