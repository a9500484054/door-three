<template>
  <div>
    <!-- Контейнер для сцены -->
    <div id="three-container" ref="container"></div>

    <!-- Элементы управления -->
    <div id="controls">
      <div>
        <label>Ширина двери:</label>
        <input type="number" v-model="doorWidth" min="1" max="5" step="0.1" />
      </div>
      <div>
        <label>Высота двери:</label>
        <input type="number" v-model="doorHeight" min="2" max="10" step="0.1" />
      </div>
      <div>
        <button @click="resetDimensions">Cбросить</button>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, watch, onMounted } from 'vue';
import * as THREE from 'three';
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';

// Ссылки и реактивные свойства
const container = ref<HTMLDivElement | null>(null);
const doorWidth = ref(1);
const doorHeight = ref(2);

let renderer: THREE.WebGLRenderer;
let door: THREE.Mesh;
let topFrame: THREE.Mesh;
let leftFrame: THREE.Mesh;
let rightFrame: THREE.Mesh;
let handleGroup1: THREE.Group;
let handleGroup2: THREE.Group;
let keyholeGroup1: THREE.Group;
let keyholeGroup2: THREE.Group;
let stripesGroup: THREE.Group;
let stripeWidth:number;
let stripeHeight2:number;

const resetDimensions = () => {
  doorWidth.value= 1
  doorHeight.value= 2
}


const createScene = () => {
  if (!container.value) {
    console.error('Контейнер для сцены не найден.');
    return;
  }

  // Создание сцены
  const scene = new THREE.Scene();

  // Камера
  const camera = new THREE.PerspectiveCamera(
    75,
    window.innerWidth / window.innerHeight,
    0.1,
    1000
  );
  camera.position.set(5, 5, 5);

  // Рендерер
  renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.shadowMap.enabled = true;

  // Добавляем canvas в DOM
  container.value.appendChild(renderer.domElement);

  // Источник света
  const light = new THREE.DirectionalLight(0xffffff, 1);
  light.position.set(5, 10, 5);
  light.castShadow = true;
  scene.add(light);

  // Окружение
  const ambientLight = new THREE.AmbientLight(0x404040, 0.5);
  scene.add(ambientLight);

  // Геометрия: куб
  const box = new THREE.Mesh(
    new THREE.BoxGeometry(1, 1, 1),
    new THREE.MeshStandardMaterial({ color: 0x00ff00  })
  );
  box.position.set(3, 0.5, 0);
  box.castShadow = true;
  scene.add(box);

  // Геометрия: сфера
  const sphere = new THREE.Mesh(
    new THREE.SphereGeometry(0.5, 32, 32),
    new THREE.MeshStandardMaterial({ color: 0x800080 })
  );
  sphere.position.set(-3, 0.5, 0);
  sphere.castShadow = true;
  scene.add(sphere);

  // Загрузка текстуры дерева
  const textureLoader = new THREE.TextureLoader();
  const woodTexture = textureLoader.load(`${import.meta.env.BASE_URL}texture2.png`);

  // URL изображения
  const imageURL = 'https://media.istockphoto.com/id/1368264124/ru/%D1%84%D0%BE%D1%82%D0%BE/%D1%8D%D0%BA%D1%81%D1%82%D1%80%D0%B5%D0%BC%D0%B0%D0%BB%D1%8C%D0%BD%D1%8B%D0%B9-%D0%BA%D1%80%D1%83%D0%BF%D0%BD%D1%8B%D0%B9-%D0%BF%D0%BB%D0%B0%D0%BD-%D0%B8%D0%B7%D1%83%D0%BC%D1%80%D1%83%D0%B4%D0%BD%D1%8B%D1%85-%D0%BE%D0%BA%D0%B5%D0%B0%D0%BD%D1%81%D0%BA%D0%B8%D1%85-%D0%B2%D0%BE%D0%BB%D0%BD.jpg?s=1024x1024&w=is&k=20&c=m3P-GCB-oJQLp4p6469cwtySgYPfT-K2GEoX4vxQ1Ig=';

  // загружаем изображение и устанавливаем его как фон
  textureLoader.load(imageURL, (texture) => {
    scene.background = texture;
  });

  // Плоскость (пол)
  const plane = new THREE.Mesh(
    new THREE.PlaneGeometry(20, 20),
    new THREE.MeshStandardMaterial({ color: 0x808080 })
  );
  plane.rotation.x = -Math.PI / 2;
  plane.receiveShadow = true;
  scene.add(plane);

  // Материал для двери
  const doorMaterial = new THREE.MeshStandardMaterial({
    map: woodTexture,
    roughness: 0.8,
    metalness: 0.1,
  });

  // Геометрия двери
  const doorGeometry = new THREE.BoxGeometry(doorWidth.value, doorHeight.value, 0.1);
  door = new THREE.Mesh(doorGeometry, doorMaterial);
  door.position.set(0, doorHeight.value / 1.9, 0);
  door.castShadow = true;
  scene.add(door);

  // Создание коробки для двери
  const frameWidth = 0.1;
  const frameDepth = 0.05;

  // Верхняя часть рамы
  const topFrameGeometry = new THREE.BoxGeometry(doorWidth.value + frameWidth * 2, frameWidth, frameDepth);
  topFrame = new THREE.Mesh(topFrameGeometry, doorMaterial);
  topFrame.position.set(0, doorHeight.value + frameWidth / 2, frameDepth / 2);
  topFrame.castShadow = true;
  scene.add(topFrame);

  // Левая часть рамы
  const leftFrameGeometry = new THREE.BoxGeometry(frameWidth, doorHeight.value + frameWidth * 2, frameDepth);
  leftFrame = new THREE.Mesh(leftFrameGeometry, doorMaterial);
  leftFrame.position.set(-doorWidth.value / 2 - frameWidth / 2, doorHeight.value / 2, frameDepth / 2);
  leftFrame.castShadow = true;
  scene.add(leftFrame);

  // Правая часть рамы
  const rightFrameGeometry = new THREE.BoxGeometry(frameWidth, doorHeight.value + frameWidth * 2, frameDepth);
  rightFrame = new THREE.Mesh(rightFrameGeometry, doorMaterial);
  rightFrame.position.set(doorWidth.value / 2 + frameWidth / 2, doorHeight.value / 2, frameDepth / 2);
  rightFrame.castShadow = true;
  scene.add(rightFrame);

  // -------------------------------------------

  // Создание первой группы для ручки и основания
  handleGroup1 = new THREE.Group();

  // Создание прямоугольной ручки для первой стороны
  const handleGeometry1 = new THREE.BoxGeometry(0.1, 0.03, 0.05);
  const handleMaterial1 = new THREE.MeshStandardMaterial({
    color: 0xaaaaaa, 
    roughness: 0.4, 
    metalness: 0.9,  
  });
  const handle1 = new THREE.Mesh(handleGeometry1, handleMaterial1);
  handle1.position.set(0, 0, 0.075); 
  handle1.castShadow = true;

  // Добавление основания ручки для первой стороны
  const baseGeometry1 = new THREE.BoxGeometry(0.12, 0.04, 0.02);
  const baseMaterial1 = new THREE.MeshStandardMaterial({
    color: 0xaaaaaa,
    roughness: 0.4,
    metalness: 0.9,
  });
  const base1 = new THREE.Mesh(baseGeometry1, baseMaterial1);
  base1.position.set(0, 0, 0.09); 
  base1.castShadow = true;

  // Добавление ручки и основания в первую группу
  handleGroup1.add(handle1);
  handleGroup1.add(base1);

  // Позиционирование первой группы на двери
  handleGroup1.position.set(0.38, -0.15, 0);

  // Добавление первой группы к двери
  door.add(handleGroup1);

  // Создание второй группы для ручки и основания
  handleGroup2 = new THREE.Group();

  // Создание прямоугольной ручки для второй стороны
  const handleGeometry2 = new THREE.BoxGeometry(0.1, 0.03, 0.05);
  const handleMaterial2 = new THREE.MeshStandardMaterial({
    color: 0xaaaaaa, 
    roughness: 0.4,
    metalness: 0.9,  
  });
  const handle2 = new THREE.Mesh(handleGeometry2, handleMaterial2);
  handle2.position.set(0, 0, 0.075); 
  handle2.castShadow = true;

  // Добавление основания ручки для второй стороны
  const baseGeometry2 = new THREE.BoxGeometry(0.12, 0.04, 0.02);
  const baseMaterial2 = new THREE.MeshStandardMaterial({
    color: 0xaaaaaa,
    roughness: 0.4,
    metalness: 0.9,
  });
  const base2 = new THREE.Mesh(baseGeometry2, baseMaterial2);
  base2.position.set(0, 0, 0.09); 
  base2.castShadow = true;

  // Добавление ручки и основания во вторую группу
  handleGroup2.add(handle2);
  handleGroup2.add(base2);

  // Поворот второй группы на 180 градусов вокруг оси Y
  handleGroup2.rotation.y = Math.PI;

  // Позиционирование второй группы на двери
  handleGroup2.position.set(0.38, -0.15, 0); 

  // Добавление второй группы к двери
  door.add(handleGroup2);

// -----------------------------------------

  // Создание группы для отверстия
  keyholeGroup1 = new THREE.Group();

  // 1. Прямоугольник с закругленными углами
  const rectGeometry = new THREE.BoxGeometry(0.05, 0.05, 0.05);
  const rectMaterial = new THREE.MeshStandardMaterial({ color: 0xaaaaaa });
  const rect = new THREE.Mesh(rectGeometry, rectMaterial);
  rect.position.set(0, 0, 0);
  keyholeGroup1.add(rect);

  // 2. Круг в центре
  const circleGeometry = new THREE.CircleGeometry(0.02, 8); // Радиус круга
  const circleMaterial = new THREE.MeshStandardMaterial({ color: 0x333333 });
  const circle = new THREE.Mesh(circleGeometry, circleMaterial);
  circle.position.set(0, 0, 0.03);
  keyholeGroup1.add(circle);


  // Позиционирование группы с отверстиями на двери
  keyholeGroup1.position.set(doorWidth.value / 2 - 0.11, -0.3, 0.04);

  // Добавляем группу отверстия на дверь
  door.add(keyholeGroup1);

  // Создание группы для отверстия
  keyholeGroup2 = new THREE.Group();

  // 1. Прямоугольник с закругленными углами
  const rectGeometry2 = new THREE.BoxGeometry(0.05, 0.05, 0.05);
  const rectMaterial2 = new THREE.MeshStandardMaterial({ color: 0xaaaaaa });
  const rect2 = new THREE.Mesh(rectGeometry2, rectMaterial2);
  rect2.position.set(0, 0, 0); 
  keyholeGroup2.add(rect2);

  // 2. Круг в центре
  const circleGeometry2 = new THREE.CircleGeometry(0.02, 8); // Радиус круга
  const circleMaterial2 = new THREE.MeshStandardMaterial({ color: 0x333333 });
  const circle2 = new THREE.Mesh(circleGeometry2, circleMaterial2);
  circle2.position.set(0, 0, 0.03); 
  keyholeGroup2.add(circle2);

  // Позиционирование группы с отверстиями на двери
  keyholeGroup2.position.set(doorWidth.value / 2 - 0.11, -0.3, -0.04); 
  keyholeGroup2.rotation.y = Math.PI;

  // Добавляем группу отверстия на дверь
  door.add(keyholeGroup2);

  // -------------------------------------

  // Создание группы для полосок
  stripesGroup = new THREE.Group();

  // Ширина и высота полосок в зависимости от размеров двери
  stripeWidth = doorWidth.value * 0.7; 
  const stripeHeight = 0.01;
  const stripeDepth = 0.01; 

  const stripeGeometry = new THREE.BoxGeometry(stripeWidth, stripeHeight, stripeDepth);
  const stripeMaterial = new THREE.MeshStandardMaterial({
    color: 0x333333, 
    roughness: 0.8,
    metalness: 0.1,
  });

  // Добавление горизонтальных полосок на дверь
  for (let i = -20; i < 20; i++) {
    const stripe = new THREE.Mesh(stripeGeometry, stripeMaterial);
    stripe.position.set(-0.15, i * 0.05, 0.05); 
    stripe.castShadow = true;
    stripesGroup.add(stripe);
  }

  for (let i = -20; i < 20; i++) {
    const stripe = new THREE.Mesh(stripeGeometry, stripeMaterial);
    stripe.position.set(-0.15, i * 0.05, -0.05); 
    stripe.castShadow = true;
    stripesGroup.add(stripe);
  }

  // Создание вертикальной полоски
  const stripeWidth2 = 0.01; 
  stripeHeight2 = doorHeight.value; 
  const stripeDepth2 = 0.01; 

  const stripeGeometry2 = new THREE.BoxGeometry(stripeWidth2, stripeHeight2, stripeDepth2);
  const stripeMaterial2 = new THREE.MeshStandardMaterial({
    color: 0x333333,
    roughness: 0.8,
    metalness: 0.1,
  });

  // Создание и позиционирование вертикальной полоски на двери
  const stripe2 = new THREE.Mesh(stripeGeometry2, stripeMaterial2);
  stripe2.position.set(0.2, 0, 0.055); // Позиция полоски на двери
  stripe2.castShadow = true;
  stripesGroup.add(stripe2);

  const stripe3 = new THREE.Mesh(stripeGeometry2, stripeMaterial2);
  stripe3.position.set(0.2, 0, -0.055); // Позиция полоски на двери
  stripe3.castShadow = true;
  stripesGroup.add(stripe3);

  // Добавление группы полосок на дверь
  door.add(stripesGroup);

  // -------------------------------------

  // Контроллер камеры
  const controls = new OrbitControls(camera, renderer.domElement);

  // Анимация
  const animate = () => {
    requestAnimationFrame(animate);
    controls.update();
    renderer.render(scene, camera);
  };
  animate();
};

function updateStripesSize() {
  const newStripeWidth = doorWidth.value * 0.7;
  const newStripeHeight = doorHeight.value;

  stripesGroup.scale.set(newStripeWidth / stripeWidth, newStripeHeight / stripeHeight2, 1);
}

const updateDoor = () => {
  if (!door) return;

  const frameWidth = 0.1;
  const frameDepth = 0.05;

  // Обновляем геометрию двери
  const newDoorGeometry = new THREE.BoxGeometry(doorWidth.value, doorHeight.value, 0.1);
  door.geometry.dispose();
  door.geometry = newDoorGeometry;
  door.position.y = doorHeight.value / 2;

  // Обновляем геометрию верхней части рамы
  const newTopFrameGeometry = new THREE.BoxGeometry(doorWidth.value + frameWidth * 2, frameWidth, frameDepth);
  topFrame.geometry.dispose();
  topFrame.geometry = newTopFrameGeometry;
  topFrame.position.set(0, doorHeight.value + frameWidth / 2, frameDepth / 2);

  // Обновляем геометрию левой части рамы
  const newLeftFrameGeometry = new THREE.BoxGeometry(frameWidth, doorHeight.value + frameWidth * 2, frameDepth);
  leftFrame.geometry.dispose();
  leftFrame.geometry = newLeftFrameGeometry;
  leftFrame.position.set(-doorWidth.value / 2 - frameWidth / 2, doorHeight.value / 2, frameDepth / 2);

  // Обновляем геометрию правой части рамы
  const newRightFrameGeometry = new THREE.BoxGeometry(frameWidth, doorHeight.value + frameWidth * 2, frameDepth);
  rightFrame.geometry.dispose();
  rightFrame.geometry = newRightFrameGeometry;
  rightFrame.position.set(doorWidth.value / 2 + frameWidth / 2, doorHeight.value / 2, frameDepth / 2);

  // Обновляем позицию ручек
  handleGroup1.position.set(doorWidth.value / 2 - 0.1, -0.15, 0);
  handleGroup2.position.set(doorWidth.value / 2 - 0.1, -0.15, 0);
  
  // Обновляем позицию замочной скважины
  keyholeGroup1.position.set(doorWidth.value / 2 - 0.11, -0.3, 0.04);
  keyholeGroup2.position.set(doorWidth.value / 2 - 0.11, -0.3, -0.04);

  updateStripesSize()
};

// Запуск сцены после монтирования компонента
onMounted(() => {
  createScene();
  // Слежение за изменениями размеров двери
  watch([doorWidth, doorHeight], updateDoor);
});
</script>

<style>
#three-container {
  width: 100vw;
  height: 100vh;
  overflow: hidden;
}

/* Стили для блока управления */
#controls {
  position: absolute;
  top: 10px;
  left: 10px;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 20px;
  background-color: #f9f9f9;
  border-radius: 10px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  font-family: Arial, sans-serif;
}

/* Стили для каждого элемента управления */
#controls div {
  margin-bottom: 15px;
  display: flex;
  align-items: center;
}

/* Стили для меток */
#controls label {
  margin-right: 10px;
  font-size: 1.1em;
  color: #333;
}

/* Стили для полей ввода */
#controls input[type="number"] {
  width: 60px;
  padding: 5px;
  font-size: 1em;
  border: 1px solid #ccc;
  border-radius: 5px;
  text-align: center;
}

/* Стили для полей ввода при фокусе */
#controls input[type="number"]:focus {
  border-color: #007BFF;
  outline: none;
  box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
}

/* Стили для кнопки */
#controls button {
  padding: 10px 20px;
  font-size: 1em;
  color: #fff;
  background-color: #007BFF;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  transition: background-color 0.3s ease;
}

/* Стили для кнопки при наведении */
#controls button:hover {
  background-color: #0056b3;
}

/* Стили для кнопки при фокусе */
#controls button:focus {
  outline: none;
  box-shadow: 0 0 5px rgba(0, 123, 255, 0.5);
}



</style>
