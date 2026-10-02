/**
 * SPDX-FileCopyrightText: (c) 2026 Liferay, Inc. https://liferay.com
 * SPDX-License-Identifier: LGPL-2.1-or-later OR LicenseRef-Liferay-DXP-EULA-2.0.0-2023-06
 */

import {useEffect, useRef} from 'react';

interface IProps {
	autoClose?: boolean | number;
	onClose?: () => void;
}

export function useAutoClose({autoClose, onClose}: IProps) {
	const remainingTimeRef = useRef(
		autoClose === true ? 10000 : autoClose || 0
	);
	const startedAtRef = useRef<number>(0);
	const timerRef = useRef<number | null>(null);

	const pauseTimer = () => {
		if (!timerRef.current) {
			return;
		}

		remainingTimeRef.current =
			remainingTimeRef.current - (Date.now() - startedAtRef.current);

		clearTimeout(timerRef.current);

		timerRef.current = null;
	};

	const startTimer = () => {
		if (!autoClose || timerRef.current) {
			return;
		}

		startedAtRef.current = Date.now();

		timerRef.current = window.setTimeout(
			() => onClose?.(),
			remainingTimeRef.current
		);
	};

	useEffect(() => {
		startTimer();

		return pauseTimer;
	}, []);

	return {
		pauseAutoCloseTimer: pauseTimer,
		startAutoCloseTimer: startTimer,
	};
}
