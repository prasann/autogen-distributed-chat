from typing import List

from _publisher import publish_message_to_ui_and_backend
from _types import GroupChatMessage, RequestToSpeak, UIAgentConfig
from autogen_core import MessageContext, RoutedAgent, message_handler
from autogen_core.models import (
    AssistantMessage,
    ChatCompletionClient,
    LLMMessage,
    SystemMessage,
    UserMessage,
)
from rich.console import Console
from rich.markdown import Markdown


class BaseGroupChatAgent(RoutedAgent):
    """A group chat participant using an LLM."""

    def __init__(
        self,
        description: str,
        group_chat_topic_type: str,
        model_client: ChatCompletionClient,
        system_message: str,
        ui_config: UIAgentConfig,
    ) -> None:
        super().__init__(description=description)
        self._group_chat_topic_type = group_chat_topic_type
        self._model_client = model_client
        self._system_message = SystemMessage(content=system_message)
        self._chat_history: List[LLMMessage] = []
        self._ui_config = ui_config
        self.console = Console()

    @message_handler
    async def handle_message(
        self, message: GroupChatMessage, ctx: MessageContext
    ) -> None:
        self._chat_history.extend(
            [
                UserMessage(
                    content=f"Transferred to {message.body.source}", source="system"
                ),  # type: ignore[union-attr]
                message.body,
            ]
        )

    @message_handler
    async def handle_request_to_speak(
        self, message: RequestToSpeak, ctx: MessageContext
    ) -> None:
        self._chat_history.append(
            UserMessage(
                content=f"Transferred to {self.id.type}, adopt the persona immediately.",
                source="system",
            )
        )
        completion = await self._model_client.create(
            [self._system_message] + self._chat_history
        )
        assert isinstance(completion.content, str)
        self._chat_history.append(
            AssistantMessage(content=completion.content, source=self.id.type)
        )

        console_message = f"\n{'-' * 80}\n**{self.id.type}**: {completion.content}"
        self.console.print(Markdown(console_message))

        await publish_message_to_ui_and_backend(
            runtime=self,
            source=self.id.type,
            user_message=completion.content,
            ui_config=self._ui_config,
            group_chat_topic_type=self._group_chat_topic_type,
        )
