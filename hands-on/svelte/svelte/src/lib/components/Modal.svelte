<script>
	export let show = false;
	export let message = '';
	const close = () => {
		show = false;
		dispatch('close');
	};
	import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();
</script>

{#if show}
	<div class="modal-overlay" on:click={() => dispatch('close')}>
		<div class="modal" on:click|stopPropagation>
			<p>{message}</p>
			<button on:click={() => dispatch('close')}>Close</button>
		</div>
	</div>
{/if}

<style>
	.modal-overlay {
		position: fixed;
		top: 0; left: 0;
		width: 100%; height: 100%;
		background: rgba(0, 0, 0, 0.5);
		display: flex;
		justify-content: center;
		align-items: center;
		z-index: 1000;
	}
	.modal {
		background: #fff;
		padding: 20px;
		border-radius: 8px;
		box-shadow: 0 2px 10px rgba(0,0,0,0.2);
		max-width: 90%;
	}
	button {
		margin-top: 15px;
		padding: 8px 16px;
		border: none;
		background: #007bff;
		color: #fff;
		border-radius: 4px;
		cursor: pointer;
	}
	button:hover {
		background: #0056b3;
	}
</style>
