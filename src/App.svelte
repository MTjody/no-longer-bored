<script lang="ts">
  async function getActivity() {
    const prom = new Promise(async (resolve, reject) => {
      let res = await fetch("http://www.boredapi.com/api/activity/");
      const json = await res.json();

      setTimeout(() => {
        resolve(json);
      }, 1000);
    });

    const res = await prom;

    console.info({ res });
    const text = res["activity"];

    if (res) {
      return text;
    } else {
      throw new Error(text);
    }
  }

  let promise = getActivity();

  function handleClick() {
    promise = getActivity();
  }
</script>

<main>
  <h1>Bored today?</h1>
  <p>Fear not! I have a suggestion!</p>

  {#await promise}
    <p class="typing text">Give me a second here...</p>
  {:then activity}
    <p class="text">{activity}</p>
  {:catch error}
    <p>Gosh dangit! {error}</p>
  {/await}
</main>

<style>
  main {
    text-align: center;
    height: 75%;
    padding: 1em;
    max-width: 240px;
    margin: auto;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
  }

  h1 {
    color: #ff3e00;
    text-transform: uppercase;
    font-size: 4em;
    font-weight: 100;
  }

  @media (min-width: 640px) {
    main {
      max-width: none;
    }
  }

  .typing {
    text-align: center;
    width: 24ch;
    animation: typing 0.9s steps(24), blink 0.5s step-end infinite alternate;
    white-space: nowrap;
    overflow: hidden;
    border-right: 3px solid;
  }

  .text {
    font-family: monospace;
    font-size: 2em;
  }

  @keyframes typing {
    from {
      width: 0;
    }
  }
  @keyframes blink {
    50% {
      border-color: transparent;
    }
  }
</style>
