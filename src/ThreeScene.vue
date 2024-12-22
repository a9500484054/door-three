<template>
    <div>
      <!-- Контейнер для сцены -->
      <div id="three-container" ref="container"></div>
  
      <!-- Элементы управления -->
      <div id="controls">
        <label>Ширина двери:</label>
        <input type="number" v-model="doorWidth" min="1" max="5" step="0.1" />
        <label>Высота двери:</label>
        <input type="number" v-model="doorHeight" min="2" max="10" step="0.1" />
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
  
    // Окружение (ambient light)
    const ambientLight = new THREE.AmbientLight(0x404040, 0.5);
    scene.add(ambientLight);

    // Геометрия: куб
    const box = new THREE.Mesh(
    new THREE.BoxGeometry(1, 1, 1),
    new THREE.MeshStandardMaterial({ color: 0xff0000 })
    );
    box.position.set(-3, 0.5, 0);
    box.castShadow = true;
    scene.add(box);

      // Геометрия: сфера
      const sphere = new THREE.Mesh(
        new THREE.SphereGeometry(0.5, 32, 32),
        new THREE.MeshStandardMaterial({ color: 0x0000ff })
      );
      sphere.position.set(3, 0.5, 0);
      sphere.castShadow = true;
      scene.add(sphere);
  
    // Загрузка текстуры дерева
    const textureLoader = new THREE.TextureLoader();
    const woodTexture = textureLoader.load(`${import.meta.env.BASE_URL}textur.png`);    
    

    const doorGeometry = new THREE.BoxGeometry(doorWidth.value, doorHeight.value, 0.1);
    const doorMaterial = new THREE.MeshStandardMaterial({
        map: woodTexture, // Применяем текстуру дерева
    });

    // Геометрия: дверь
    door = new THREE.Mesh(doorGeometry, doorMaterial);
    door.position.set(0, doorHeight.value / 2, 0);
    door.castShadow = true;
    scene.add(door);
  
    // Плоскость (пол)
    const plane = new THREE.Mesh(
      new THREE.PlaneGeometry(20, 20),
      new THREE.MeshStandardMaterial({ color: 0x808080 })
    );
    plane.rotation.x = -Math.PI / 2;
    plane.receiveShadow = true;
    scene.add(plane);
  
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
  
  const updateDoor = () => {
    if (!door) return;
  
    // Удаляем старую геометрию
    const newGeometry = new THREE.BoxGeometry(doorWidth.value, doorHeight.value, 0.1);
  
    door.geometry.dispose(); // Удаляем старую геометрию
    door.geometry = newGeometry; // Присваиваем новую геометрию
    door.position.y = doorHeight.value / 2; // Обновляем позицию
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
  
  #controls {
    position: absolute;
    top: 10px;
    left: 10px;
    background: rgba(255, 255, 255, 0.9);
    padding: 10px;
    border-radius: 5px;
  }
  
  label {
    font-size: 14px;
  }
  
  input {
    margin-bottom: 5px;
    width: 100px;
  }
  </style>
  